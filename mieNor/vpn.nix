{ config, lib, pkgs, ... }:
let watchdogIp = "10.42.42.3";
in {
  networking.wg-quick.interfaces.dmnt = {
    type = "amneziawg";
    configFile = "/etc/secrets/dmnt.awg.conf";
  };

  # AmneziaWG tunnel watchdog
  systemd.services.dmnt-watchdog = {
    description = "AmneziaWG tunnel watchdog";
    after = [ "wg-quick-dmnt.service" ];
    path = [ pkgs.iputils pkgs.coreutils ];
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
          systemctl restart wg-quick-dmnt.service
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
