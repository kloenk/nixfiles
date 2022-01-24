{ config, lib, pkgs, ... }:

let
  commonHeaders = lib.concatStringsSep "\n"
    (lib.filter (line: lib.hasPrefix "add_header" line)
      (lib.splitString "\n" config.services.nginx.commonHttpConfig));
in {
  fileSystems."/var/lib/pleroma" = {
    device = "/persist/data/pleroma";
    fsType = "none";
    options = [ "bind" ];
  };

  services.pleroma = {
    enable = true;
    configs = [ (lib.fileContents ./config.exs) ];
    secretConfigFile = config.petabyte.secrets."pleroma/config.secret.exs".path;
  };

  systemd.services.pleroma.serviceConfig.RuntimeDirectory = "pleroma";
  systemd.services.pleroma.environment = {
    DOMAIN = "social.kloenk.dev";
  };
  systemd.sockets.pleroma = {
    description = "Pleroma socket";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "/run/pleroma/pleroma.socket" ];
    socketConfig = {
      SocketUser = "pleroma";
      SocketGroup = "nginx";
    };
  };

  services.nginx.virtualHosts."social.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    locations = let
      upstream = "http://unix:/run/pleroma/pleroma.socket";
    in {
      "/" = {
        proxyPass = upstream;
        proxyWebsockets = true;
      };
      #"~* ^.+\.(css|cur|gif|gz|ico|jpg|jpeg|js|png|svg|woff|woff2)$" = {
      "/static/" = {
        root = "${config.services.pleroma.package}/lib/pleroma-${config.services.pleroma.package.version}/priv/static/";
        extraConfig = ''
          etag off;
          expires max;
          ${commonHeaders}
          add_header Cache-Control public;
        '';
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "pleroma" ];
    ensureUsers = [
      {
        name = "pleroma";
        ensurePermissions."DATABASE pleroma" = "ALL PRIVILEGES";
      }
    ];
  };


  petabyte.secrets."pleroma/config.secret.exs".owner = "pleroma";
}
