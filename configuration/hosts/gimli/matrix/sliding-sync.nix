{ config, lib, pkgs, ... }:

{
  services.matrix-sliding-sync-proxy = {
    enable = true;
    dbName = "syncv3";
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
