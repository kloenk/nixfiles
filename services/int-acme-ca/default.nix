{ lib, config, self, ... }:

{
  fileSystems."/var/lib/private/step-ca" = {
    device = "/persist/data/step-ca";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.firewall.allowedTCPPorts = [ 8443 ];
  services.step-ca = {
    enable = true;
    address = "[2a01:4f8:c013:1a4b:ecba:1337::1]";
    port = 8443;
    intermediatePasswordFile =
      config.sops.secrets."int-acme-ca/intermediate-ca-passphrase".path;
    settings = {
      dnsNames = [ "acme.net.kloenk.de" ];
      root = ../../lib/kloenk-int-ca.crt;
      crt = ../../lib/kloenk-int-acme.crt;
      key = config.sops.secrets."int-acme-ca/intermediate-ca-key".path;
      db = {
        type = "badger";
        dataSource = "/var/lib/step-ca/db";
      };
      authority = {
        provisioners = [{
          type = "ACME";
          name = "acme";
          claims = {
            maxTLSCertDuration = "720h";
            defaultTLSCertDuration = "720h";
          };
        }];
      };
    };
  };

  #systemd.services.step-ca.serviceConfig.BindPaths =
  #    "/persist/data/step-ca:/var/lib/step-ca";
  systemd.services.step-ca.serviceConfig.ReadWritePaths =
    "/persist/data/step-ca";

  sops.secrets = {
    "int-acme-ca/intermediate-ca-key".owner = "step-ca";
    "int-acme-ca/intermediate-ca-passphrase".owner = "step-ca";
  };
}
