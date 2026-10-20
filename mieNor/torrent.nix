{ config, lib, pkgs, ... }:
let
  downloadsDir = "/data/media/torrents";
in
{
  # Settings live in qBittorrent.conf, managed via the web UI.
  # serverConfig is left unset: the module overwrites the conf on every start when it's set.
  services.qbittorrent = {
    enable = true;
    group = "data";
    webuiPort = 37410;
    torrentingPort = 37030;
  };

  systemd.services.qbittorrent.serviceConfig = {
    UMask = "0027";
    Restart = "always";
    RestartSec = 5;
  };

  systemd.tmpfiles.settings."40-qbittorrent" = {
    "${lib.removeSuffix "/" config.services.qbittorrent.profileDir}/vuetorrent"."L+".argument =
      "${pkgs.vuetorrent}/share/vuetorrent";
    ${downloadsDir}.d = {
      user = "servant";
      group = "data";
      mode = "2770";
    };
    "${downloadsDir}/.incomplete".d = {
      user = "servant";
      group = "data";
      mode = "2770";
    };
  };
}
