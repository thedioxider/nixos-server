{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ### Hardware-dependent options
    ./hardware-configuration.nix

    ### Programs, Services & Environment
    ./env.nix

    ### Power management & Sleep configs
    ./power.nix

    ### Network
    ./network.nix

    ### Plasma Desktop
    ./plasma.nix
  ];

  ### NixOS special options
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
    options = "--delete-older-than 90d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "monthly" ];
  };

  ### Boot
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
  };

  ### System
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Moscow";

  # enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      AllowUsers = [ "root" "dio" "share" "amnezia" ];
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
      PermitRootLogin =
        "forced-commands-only"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      TCPKeepAlive = true;
      ClientAliveInterval = 60;
      ClientAliveCountMax = 60;
    };
    extraConfig = ''
      Subsystem sftp internal-sftp -u 0002
      Match User share
        PasswordAuthentication yes
        ChallengeResponseAuthentication yes
        ChrootDirectory /share
        ForceCommand internal-sftp -d /files
        AllowTcpForwarding no
        PermitTunnel no
        X11Forwarding no
      Match All
    '';
  };
  security.pam.services.sshd.unixAuth = pkgs.lib.mkForce true;

  ### Users & Groups
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKHF6abqEUyjJGM4oCSq6i7aFnQyzvHb+flLb/Y4tlE"
  ];

  users.groups.nixos.members = [ "root" "dio" ];
  users.groups.share = { };

  users.users = {
    dio = {
      description = "Demetrius R.";
      isNormalUser = true;
      uid = 1134;
      initialHashedPassword =
        "$y$j9T$mH5EZb/OBF8ACbwFGIEHa1$5Cw0t9dqll73lpN2vATJU9RW03/MWlPs.PwpgrZd0m0";
      useDefaultShell = false;
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      packages = with pkgs; [ ];
    };

    share = {
      description = "Share files and leave something good";
      isNormalUser = true;
      group = "share";
      hashedPassword =
        "$y$j9T$9ISDrRxqstIQpxJVYym761$siuHijPXpf2ccGmSdqyOUfeusNc9JxvQZtMbm61Se2D";
      useDefaultShell = false;
      shell = pkgs.fish;
    };

    amnezia = {
      description = "Amnezia";
      isNormalUser = true;
      hashedPassword =
        "$y$j9T$geZ5r24UA3IU.D1TQscJP.$1IScpCuHr.nFja7ARYgbzXDxSc9fKL/vov0ieq.NOH4";
      extraGroups = [ "wheel" ];
    };
  };

  systemd.tmpfiles.settings."10-share" = {
    "/share".d = {
      user = "root";
      group = "users";
      mode = "0751";
    };
    "/share/files".d = {
      user = "share";
      group = "share";
      mode = "0777";
    };
  };

  #
  #
  #
  #
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
