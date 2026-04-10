{ pkgs, ... }:
{
  users.groups = {
    data.members = [ "root" ];
    share.members = [ "root" ];
  };

  systemd.tmpfiles.settings."10-data" = {
    "/storage".d = {
      user = "root";
      group = "data";
      mode = "0770";
    };

    "/data".d = {
      user = "servant";
      group = "data";
      mode = "2770";
    };
  };

  systemd.tmpfiles.settings."20-services" = {
    "/server".d = {
      user = "root";
      group = "server";
      mode = "2750";
    };
    "/server/services".d = {
      user = "servant";
      group = "server";
      mode = "2770";
    };
  };

  systemd.tmpfiles.settings."30-share" = {
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
}
