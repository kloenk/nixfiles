{ config, lib, pkgs, ... }:

{
  fileSystems."/var/lib/netbox" = {
    device = "/persist/data/netbox";
    fsType = "none";
    options = [ "bind" ];
  };

  services.netbox = {
    enable = true;
    package = pkgs.netbox_3_7;
    secretKeyFile = config.sops.secrets."netbox/secret_key".path;
    keycloakClientSecret = config.sops.secrets."netbox/keycloak_secret".path;
    settings = {
      REMOTE_AUTH_ENABLED = true;
      REMOTE_AUTH_BACKEND = "social_core.backends.keycloak.KeycloakOAuth2";
      SOCIAL_AUTH_KEYCLOAK_KEY = "netbox";
      SOCIAL_AUTH_KEYCLOAK_PUBLIC_KEY =
        "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA345Ca98F79JMfDEfJWT5t9ufUahIX0ukpQLYrBpV7Ri5qUbmf/Z5r56ZASApGSasBcu//za0i1TyiTfhEI0ihbUZqOeQB83Dw7PewebqbIHYlmg16qsfLjKcnt2tZXR8k+yWRPlvtjzEMvUM8zKPH4fYu4WuRMLDKQ7hfi+V/QcsXGJbrk3f21d2uuWFVPZaOvea/VuvYz7NkXzSCsX0eD6PwzM+Z+EQgFbh+42TpNkz/Ww/sOv0vfK2MwQqj8XhtNc8lxlIv6YxAaAPBxdSP976Iwyp8nQ5ZfQVQhetfttko8nG+DJ6lI1PNnow2Ni8nXYOCaOALW1rNBQVkn8j3wIDAQAB";
      SOCIAL_AUTH_KEYCLOAK_AUTHORIZATION_URL =
        "https://auth.kloenk.dev/realms/kloenk/protocol/openid-connect/auth";
      SOCIAL_AUTH_KEYCLOAK_ACCESS_TOKEN_URL =
        "https://auth.kloenk.dev/realms/kloenk/protocol/openid-connect/token";
    };
    port = lib.getPort "netbox-old";
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "netbox" ];
    ensureUsers = [{
      name = "netbox";
      ensureDBOwnership = true;
    }];
  };

  services.nginx.virtualHosts."netbox.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString (lib.getPort "netbox-old")}";
      proxyWebsockets = true;
    };
    locations."/static/".root = "/var/lib/netbox";
  };
  users.users.nginx.extraGroups = [ "netbox" ];

  sops.secrets."netbox/secret_key".owner = "netbox";
  sops.secrets."netbox/keycloak_secret".owner = "netbox";

  /* backups.netbox = {
       user = "netbox";
       paths = [ "/persist/data/netbox" ];
       postgresDatabases = [ "netbox" ];
     };
  */
}
