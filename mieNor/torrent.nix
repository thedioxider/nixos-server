{ pkgs, ... }:
let
  stateDir = "/data/var/qbittorrent";
in
{
  # Settings live in qBittorrent.conf, managed via the web UI.
  # serverConfig is left unset: the module overwrites the conf on every start when it's set.
  services.qbittorrent = {
    enable = true;
    group = "data";
    profileDir = stateDir;
    webuiPort = 37410;
    torrentingPort = 37030;
  };

  systemd.services.qbittorrent.serviceConfig.UMask = "0027";

  systemd.tmpfiles.settings."40-qbittorrent" = {
    ${stateDir}.d = {
      user = "qbittorrent";
      group = "data";
      mode = "0750";
    };
    "${stateDir}/incomplete".d = {
      user = "qbittorrent";
      group = "data";
      mode = "0750";
    };
    "${stateDir}/vuetorrent"."L+".argument = "${pkgs.vuetorrent}/share/vuetorrent";
    "/data/media/torrents".d = {
      user = "qbittorrent";
      group = "data";
      mode = "2750";
    };
  };
}
