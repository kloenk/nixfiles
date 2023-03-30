{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.matrix-sliding-sync-proxy;
  user = if cfg.user == null then "matrix-sliding-sync-proxy" else cfg.user;
in {
  config = mkIf cfg.enable {
    assertions = [{
      assertion = cfg.dbName != null;
      message = ''
        A Postgres database is required for matrix-sliding-sync-proxy to work.

        See `services.matrix-sliding-sync-proxy.db` in `man configuration.nix` for details.
      '';
    }];
    systemd.services.matrix-sliding-sync = {
      script = ''
        cd ${cfg.package}/share
        exec ${cfg.package}/bin/syncv3
      '';
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = { User = user; };
      environment = {
        SYNCV3_DB =
          "user=${user} dbname=${cfg.dbName} sslmode=disable host=${cfg.dbHost}";
        SYNCV3_BINDADDR = "${cfg.bind}";
        SYNCV3_SERVER = "${cfg.server}";
        SYNCV3_SECRET = "foobar";
      };
    };

    users = mkIf (cfg.user == null) {
      users.matrix-sliding-sync-proxy = {
        isSystemUser = true;
        group = "matrix-sliding-sync-proxy";
      };
      groups.matrix-sliding-sync-proxy = { };
    };
  };
  options = {
    services.matrix-sliding-sync-proxy = {
      enable = mkEnableOption "the experimental matrix sliding sync proxy";
      package = mkOption {
        type = types.package;
        default = pkgs.matrix-sliding-sync-proxy;
        description = "Package to use for the service.";
      };
      server = mkOption {
        type = types.str;
        default = "https://localhost:8448/";
        description = "Server to proxy requests for.";
      };
      dbName = mkOption {
        default = null;
        type = types.nullOr types.str;
        example = "syncv3";
        description = "Postgres database name to access.";
      };
      bind = mkOption {
        type = types.str;
        default = "localhost:8008";
        description = "Port to bind the proxy to.";
      };
      dbHost = mkOption {
        default = "/run/postgresql";
        type = types.str;
        description = "Path to postgresql socket.";
      };
      user = mkOption {
        default = null;
        description =
          "User under which the service runs. Created automatically if null.";
      };
    };
  };
}
