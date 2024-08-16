{ lib, config, pkgs, ... }:

{
  services.homebox = {
    enable = true;
    package = pkgs.homebox.overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        substituteInPlace frontend/pages/index.vue \
          --replace 'homebox-dev' 'homebox' \
          --replace '%3A%2F%2Flocalhost%3A3000' 's%3A%2F%2Farmory.kloenk.dev'
      '';
    });
    settings = {
      HBOX_WEB_PORT = toString (lib.getPort "homebox");
      HBXO_WEB_HOST = "[::1]";
      HBOX_OAUTH_OIDC_URL = "https://auth.kloenk.dev/realms/kloenk";
      HBOX_OAUTH_OIDC_ID = "homebox";
      HBOX_OAUTH_OIDC_REDIRECT = "https://armory.kloenk.dev/auth/oidc/callback";
    };
    settingsFile = config.sops.secrets."homebox/env".path;
  };

  services.nginx.virtualHosts."armory.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString (lib.getPort "homebox")}";
    };
  };

  sops.secrets."homebox/env".owner = "root";
}
