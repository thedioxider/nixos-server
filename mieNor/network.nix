{ config, lib, pkgs, ... }: {
  imports = [ ./amneziawg.nix ];

  boot.extraModulePackages = with config.boot.kernelPackages; [ amneziawg ];

  services = {
    zerotierone = {
      enable = true;
      joinNetworks = [ "d5e5fb65370f636a" ];
    };
  };

  networking.networkmanager.enable = true;

  networking.firewall = { enable = false; };
}
