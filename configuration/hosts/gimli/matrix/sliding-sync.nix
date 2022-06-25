{ config, lib, pkgs, ... }:

{
  services.matrix-sliding-sync-proxy = {
    enable = true;
    dbName = "syncv3 host=/var/run/postgresql";
    bind = ":8009";
    server = "http://localhost:8008/";
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "matrix-sliding-sync-proxy";
        ensurePermissions."DATABASE syncv3" = "ALL PRIVILEGES";
      }
    ];
    ensureDatabases = [ "syncv3" ];
  };
}
