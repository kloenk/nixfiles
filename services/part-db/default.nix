{ config, pkgs, ... }:

{
  fileSystems."/var/lib/part-db" = {
    device = "/persist/data/part-db";
    fsType = "none";
    options = [ "bind" ];
  };

  services.part-db = {
    enable = true;
    virtualHost = "parts.kloenk.dev";
    settings = {
      DEFAULT_TIMEZONE = "UTC";
      INSTANCE_NAME = "Kloenk's parts";
      DEFAULT_URI = "https://parts.kloenk.dev/";
      CHECK_FOR_UPDATES = "0";
      EDA_KICAD_CATEGORY_DEPTH = "2";
      SAML_ENABLED = "1";
      SAML_SP_ENTITY_ID = "https://parts.kloenk.dev/sp";
      SAML_IDP_ENTITY_ID = "https://auth.kloenk.dev/realms/kloenk";
      SAML_IDP_SINGLE_SIGN_ON_SERVICE =
        "https://auth.kloenk.dev/realms/kloenk/protocol/saml";
      SAML_IDP_SINGLE_LOGOUT_SERVICE =
        "https://auth.kloenk.dev/realms/kloenk/protocol/saml";
      SAML_IDP_X509_CERT =
        "MIICmzCCAYMCBgGNJsk1eTANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZrbG9lbmswHhcNMjQwMTIwMTIxMDM3WhcNMzQwMTIwMTIxMjE3WjARMQ8wDQYDVQQDDAZrbG9lbmswggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDfjkJr3wXv0kx8MR8lZPm3259RqEhfS6SlAtisGlXtGLmpRuZ/9nmvnpkBICkZJqwFy7//NrSLVPKJN+EQjSKFtRmo55AHzcPDs97B5upsgdiWaDXqqx8uMpye3a1ldHyT7JZE+W+2PMQy9QzzMo8fh9i7ha5EwsMpDuF+L5X9ByxcYluuTd/bV3a65YVU9lo695r9W69jPs2RfNIKxfR4Po/DMz5n4RCAVuH7jZOk2TP9bD+w6/S98rYzBCqPxeG01zyXGUi/pjEBoA8HF1I/3vojDKnydDll9BVCF61+22Sjycb4MnqUjU82ejDY2Lyddg4Jo4AtbWs0FBWSfyPfAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAKY4TZncAEwkT+BjiaJ8GacnQdp/gXv/Jcr2oajMfHLFe94M5Ozuk1H5C2+94MvGLVJq0sozoA7owK/6JOSUYuoj21Ynn5eiLHGPx5D+BvqZrSw8N2IkaR8a+M4Zgeeg1d087gQtugbAd3u5orwsIxWWfjmG6l6QkwQN43BJ9HklWqZlI/zCnZ0RQYSrzPMKJjQhfhguN5+dp0+I1d9NmFd2SPOijS5W9rT1/nq2dLj4wwA8RQTFy8B7lOxKlLL6jNvba/5YjwPgcINX/ieTSv2HeQFSLv36DxHDICCHtgYfil7tWeFW85Fk07fhqnH4Xi57ymr+5nm3tUJY3M/I5oM=";
      SAML_ROLE_MAPPING = ''{\"admin\":  1, \"editor\": 3, \"*\": 2}'';
    };
  };

  services.nginx.virtualHosts."parts.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
  };

  systemd.services = {
    "part-db-migrate".serviceConfig = {
      ExecStartPre = let
        execStartPre = pkgs.writeShellScript "part-db-gen-secret" ''
          cat ${
            config.systemd.tmpfiles.settings."part-db"."/var/lib/part-db/env.local"."L+".argument
          } > /var/lib/part-db/env.local
          echo "" >> /var/lib/part-db/env.local
          cat ${
            config.sops.secrets."part-db/env".path
          } >> /var/lib/part-db/env.local
        '';
      in [ "!${execStartPre}" ];
      EnvironmentFile = [ config.sops.secrets."part-db/env".path ];
    };
    "phpfpm-part-db".serviceConfig.EnvironmentFile =
      [ config.sops.secrets."part-db/env".path ];
  };
  systemd.tmpfiles.settings."part-db"."/var/lib/part-db/env.local"."L+".type =
    "f";

  sops.secrets."part-db/env".owner = "root";
}
