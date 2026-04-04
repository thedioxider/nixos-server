{ pkgs, ... }:
let
  watchdogIp = "10.8.1.9";
  awgConfigFile = "/etc/secrets/dmnt.conf";
  awgPath = [
    pkgs.unstable.amneziawg-tools
    pkgs.unstable.amneziawg-go
    pkgs.iptables
    pkgs.iproute2
  ];
in
{
  # Blacklist kernel module — crashes on 6.12.x (jp_spec_applymods page fault)
  # Forces awg-quick to use amneziawg-go userspace implementation instead
  boot.blacklistedKernelModules = [ "amneziawg" ];
  systemd.services.awg-dmnt = {
    description = "AmneziaWG tunnel (userspace) - dmnt";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = awgPath;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      awg-quick up ${awgConfigFile}
    '';
    preStop = ''
      awg-quick down ${awgConfigFile}
    '';
  };

  # AmneziaWG tunnel watchdog
  systemd.services.dmnt-watchdog = {
    description = "AmneziaWG tunnel watchdog";
    after = [ "awg-dmnt.service" ];
    path = [
      pkgs.iputils
      pkgs.coreutils
      pkgs.systemd
    ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "dmnt-watchdog";
    };
    script = ''
      STATE_FILE="/var/lib/dmnt-watchdog/failures"
      THRESHOLD=15

      if ping -c 1 -W 10 -I dmnt ${watchdogIp} &>/dev/null; then
        echo 0 > "$STATE_FILE"
      else
        FAILURES=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
        FAILURES=$((FAILURES + 1))
        echo "$FAILURES" > "$STATE_FILE"

        if [ "$FAILURES" -ge "$THRESHOLD" ]; then
          echo "Tunnel unreachable for $FAILURES checks, restarting..."
          systemctl restart awg-dmnt.service
          echo 0 > "$STATE_FILE"
        fi
      fi
    '';
  };

  systemd.timers.dmnt-watchdog = {
    description = "Run AmneziaWG watchdog every minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1min";
      AccuracySec = "5s";
    };
  };
}
