{ config, lib, pkgs, ... }: {
  networking.wg-quick.interfaces.dmnt = {
    type = "amneziawg";
    configFile = "/etc/secrets/dmnt.awg.conf";
  };
}
