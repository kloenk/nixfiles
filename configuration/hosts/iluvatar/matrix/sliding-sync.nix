{ config, lib, pkgs, ... }:

{
  services.matrix-sliding-sync-proxy = {
    enable = true;
    dbName = "syncv3";
    bind = ":8009";
    server = "http://localhost:8008";
    package = pkgs.matrix-sliding-sync;
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 8009 ];

  services.postgresql = {
    ensureUsers = [{
      name = "matrix-sliding-sync-proxy";
      ensurePermissions."DATABASE syncv3" = "ALL PRIVILEGES";
    }];
    ensureDatabases = [ "syncv3" ];
  };
}
