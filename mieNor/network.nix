{ config, lib, pkgs, ... }: {
  services = {
    zerotierone = {
      enable = true;
      joinNetworks = [ "d5e5fb65370f636a" ];
    };

  };
}
