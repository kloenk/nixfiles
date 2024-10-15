{ config, lib, pkgs, ... }:

{
  fileSystems."/var/lib/private/keycloak" = {
    device = "/persist/data/keycloak";
    fsType = "none";
    options = [ "bind" ];
  };

  services.keycloak = {
    enable = true;
    package = pkgs.keycloak.override {
      extraFeatures = [ "account:v3" ];
      disabledFeatures = [ "kerberos" ];
    };
    database.passwordFile = config.sops.secrets."keycloak/db/password".path;
    initialAdminPassword = "foobar";
    plugins = with config.services.keycloak.package.plugins;
      [ keycloak-restrict-client-auth ];
    settings = {
      http-host = "127.0.0.1";
      http-port = lib.getPort "keycloak";
      hostname = "auth.kloenk.dev";
      proxy-headers = "xforwarded";
      http-enabled = true;
    };
  };

  services.nginx.virtualHosts."auth.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString (lib.getPort "keycloak")}";
      extraConfig = ''
        proxy_buffer_size          128k;
        proxy_buffers              4 256k;
        proxy_busy_buffers_size    256k;
      '';
    };
    locations."= /" = {
      return = "301 https://auth.kloenk.dev/realms/kloenk/account/";
    };
  };

  backups.keycloak = {
    user = "keycloak";
    dynamicUser = true;
    postgresDatabases = [ "keycloak" ];
  };

  sops.secrets."keycloak/db/password".owner = "root";
}
