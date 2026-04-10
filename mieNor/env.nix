{ lib, pkgs, ... }:
{
  imports = [ ];

  ### Programs, Services & Environment
  programs = {
    fish.enable = true;
    git.enable = true;
    htop.enable = true;
    less.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    yazi.enable = true;
    firefox.enable = true;
    npm.enable = true;
    java.enable = true;
  };

  services = { };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings.dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

  environment.shellAliases = { };

  environment.systemPackages =
    (with pkgs; [
      gcc
      age
      ssh-to-age
      sops
      trash-cli
      p7zip
      vim
      jq
      zip
      unzip
      lighttpd
      maliit-framework
      maliit-keyboard
    ])
    ++ (with pkgs.unstable; [
      lazygit
      amneziawg-go
      amneziawg-tools
    ]);

  environment.variables = {
    EDITOR = "nvim";
  };
}
