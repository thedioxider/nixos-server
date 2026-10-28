{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.qbittorrent;
  profileDir = lib.removeSuffix "/" cfg.profileDir;
  confFile = "${profileDir}/qBittorrent/config/qBittorrent.conf";
  vuetorrentDir = "${profileDir}/vuetorrent";
  downloadsDir = "/data/media/torrents";
  proxyHostIp =
    lib.findFirst (ip: lib.elem "proxy-host.internal" config.networking.hosts.${ip})
      (throw "proxy-host.internal is missing from networking.hosts")
      (lib.attrNames config.networking.hosts);

  # Enforced on every start; everything else stays managed via the web UI.
  # serverConfig is left unset: the module overwrites the whole conf when it's set.
  pinned = {
    BitTorrent = {
      "Session\\DefaultSavePath" = downloadsDir;
      "Session\\TempPathEnabled" = "true";
      "Session\\TempPath" = "${downloadsDir}/.incomplete";
      "Session\\FinishedTorrentExportDirectory" = "${downloadsDir}/.metainfo";
    };
    Preferences = {
      "WebUI\\ReverseProxySupportEnabled" = "true";
      "WebUI\\TrustedReverseProxiesList" = proxyHostIp;
      "WebUI\\AlternativeUIEnabled" = "true";
      "WebUI\\RootFolder" = vuetorrentDir;
    };
  };
in
{
  services.qbittorrent = {
    enable = true;
    group = "data";
    webuiPort = 37410;
    torrentingPort = 37030;
  };

  systemd.services.qbittorrent = {
    path = [ pkgs.crudini ];
    preStart = lib.concatLines (
      lib.flatten (
        lib.mapAttrsToList (
          section:
          lib.mapAttrsToList (
            key: value:
            "crudini --ini-options=nospace --set ${
              lib.escapeShellArgs [
                confFile
                section
                key
                value
              ]
            }"
          )
        ) pinned
      )
    );
    serviceConfig = {
      UMask = "0027";
      Restart = "always";
      RestartSec = 5;
    };
  };

  systemd.tmpfiles.settings."40-qbittorrent" = {
    ${vuetorrentDir}."L+".argument = "${pkgs.vuetorrent}/share/vuetorrent";
  }
  // lib.genAttrs [ downloadsDir "${downloadsDir}/.incomplete" "${downloadsDir}/.metainfo" ] (_: {
    d = {
      user = "servant";
      group = "data";
      mode = "2770";
    };
    "a+".argument = "d:g:data:rwx,g:data:rwx";
  });
}
