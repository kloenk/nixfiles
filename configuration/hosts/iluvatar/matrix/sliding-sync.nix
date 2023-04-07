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

  services.nginx.virtualHosts."Type your prompt and the code generation will just begin. To edit some existing code, you can also select something before perform this command, when accepting the change, the selected code will be replaced with the generated one.

Type your prompt and the code generation will just begin. To edit some existing code, you can also select something before perform this command, when accepting the change, the selected code will be replaced with the generated one.

matrix.kloenk.eu".locations = {
    "/_matrix/client/unstable/org.matrix.msc3575/" = {
      proxyPass =
        "http://localhost:8009/_matrix/client/unstable/org.matrix.msc3575/";
      priority = 900;
    };
  };

  services.postgresql = {
    ensureUsers = [{
      name = "matrix-sliding-sync-proxy";
      ensurePermissions."DATABASE syncv3" = "ALL PRIVILEGES";
    }];
    ensureDatabases = [ "syncv3" ];
  };
}
