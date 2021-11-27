{ config, pkgs, lib, ... }:

let
  commonHeaders = lib.concatStringsSep "\n"
    (lib.filter (line: lib.hasPrefix "add_header" line)
      (lib.splitString "\n" config.services.nginx.commonHttpConfig));

  dataDir = "/persist/data/restya";
in {
  services.restya-board = {
    enable = true;
    dataDir = dataDir;
    virtualHost = {
      serverName = "restya.kloenk.dev";
      
    };
  };

  services.nginx.virtualHosts."restya.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    http2 = true;
    listen = lib.mkForce [ ];
	locations."~* \\.(css|js|less|html|ttf|woff|jpg|jpeg|gif|png|bmp|ico)" = {
      extraConfig = ''
        ${commonHeaders}
      '';
    };
  };

  systemd.services.restya-board-init.serviceConfig.ExecStartPre = let
    dont_touch_sql = pkgs.writeShellScript "restya-dont-touch-sql" ''
      touch ${dataDir}.db-initialized
    '';
  in [ dont_touch_sql ];
}
