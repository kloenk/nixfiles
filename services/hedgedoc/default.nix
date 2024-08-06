{ config, ... }:

{
  services.hedgedoc = {
    enable = true;
    settings = {
      debug = false;
      path = "/run/hedgedoc/hedgedoc.sock";
      domain = "md.kloenk.dev";
      protocolUseSSL = true;
      allowFreeURL = true;
      email = false;
      allowEmailRegister = false;
      allowAnonymous = false;
      allowAnonymousEdits = true;
      db = {
        dialect = "postgres";
        host = "/run/postgresql";
      };
      oauth2 = {
        tokenURL =
          "https://auth.kloenk.dev/realms/kloenk/protocol/openid-connect/token";
        authorizationURL =
          "https://auth.kloenk.dev/realms/kloenk/protocol/openid-connect/auth";
        userProfileURL =
          "https://auth.kloenk.dev/realms/kloenk/protocol/openid-connect/userinfo";
        clientID = "hedgedoc";
        scope = "openid email profile";
        userProfileUsernameAttr = "preferred_username";
        userProfileDisplayNameAttr = "name";
        userProfileEmailAttr = "email";
        clientSecret = "";
      };
    };
    environmentFile = config.sops.secrets."hedgedoc/env".path;
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hedgedoc" ];
    ensureUsers = [{
      name = "hedgedoc";
      ensureDBOwnership = true;
    }];
  };

  users.users.nginx.extraGroups = [ "hedgedoc" ];
  services.nginx.virtualHosts."md.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://unix:/run/hedgedoc/hedgedoc.sock";
      proxyWebsockets = true;
    };
  };

  sops.secrets."hedgedoc/env".owner = "hedgedoc";
}
