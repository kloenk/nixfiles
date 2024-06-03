{ config, ... }:

let hostName = "inventree.kloenk.dev";
in {
  services.inventree = {
    enable = true;
    inherit hostName;
    secretKeyFile = config.sops.secrets."inventree/secret_key".path;
    config = {
      social_backends = [ "allauth.socialaccount.providers.openid_connect" ];
      /* social_providers.openid_connect = {
           APPS = [{
             provider_id = "keycloak";
             name = "Keycloak";
             client_id = "inventree";
             secret._secret = config.sops.secrets."inventree/keycloak_secret".path;
             settings.server_url = "https://auth.kloenk.dev/realms/kloenk/.well-known/openid-configuration";
           }];
         };
      */
    };
  };

  services.nginx.virtualHosts.${hostName} = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
  };

  sops.secrets."inventree/secret_key".owner = "inventree";
  sops.secrets."inventree/keycloak_secret".owner = "inventree";
}
