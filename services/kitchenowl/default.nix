{ lib, config, pkgs, ... }:

{
  fileSystems."/var/lib/private/kitchenowl" = {
    device = "/persist/data/kitchenowl";
    fsType = "none";
    options = [ "bind" ];
  };

  services.kitchenowl = {
    enable = true;

    hostName = "kitchenowl.kloenk.de";
    settings = { privacyPolicy = "https://kloenk.eu/impressum/"; };
    settingsFile = config.sops.secrets."kitchenowl/env".path;
  };

  services.nginx.virtualHosts."kitchenowl.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."= /.well-known/apple-app-site-association" = {
      root = pkgs.writeTextDir ".well-known/apple-app-site-association"
        (builtins.toJSON {
          applinks = {
            apps = [ ];
            details = [{
              appID = "4UNA4W8497.com.tombursch.kitchenowl";
              paths = [ "*" ];
            }];
          };
          webcredentials = {
            apps = [ "4UNA4W8497.com.tombursch.kitchenowl" ];
          };
        });
    };
  };

  sops.secrets."kitchenowl/env".owner = "root";
}

