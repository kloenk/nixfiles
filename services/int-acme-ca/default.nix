{ lib, config, ... }:

{
  fileSystems."/var/lib/private/step-ca" = {
    device = "/persist/data/step-ca";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.network.networks."40-lo" = {
    addresses = [{ Address = "fd4c:1796:6b06:5662::443/128"; }];
  };

  networking.firewall.allowedTCPPorts = [ 8443 ];
  services.step-ca = {
    enable = true;
    address = "[fd4c:1796:6b06:5662::443]";
    port = 8443;
    intermediatePasswordFile =
      config.sops.secrets."int-acme-ca/intermediate-ca-passphrase".path;
    settings = {
      dnsNames = [ "acme.net.kloenk.dev" ];
      root = [ ../../lib/kloenk-ca.cert.pem ../../lib/kloenk-int-ca.crt ];
      crt = ../../lib/kloenk-acme.cert.pem;
      key = config.sops.secrets."int-acme-ca/kloenk-acme.key.pem".path;
      db = {
        type = "badger";
        dataSource = "/var/lib/step-ca/db";
      };
      crl = {
        enabled = true;
        generateOnRevoke = true;
      };
      /* currently broken
         policy = {
           x509 = {
             allow = {
               dns = [ "*.net.kloenk.dev" ]
             }
           }
         }
      */
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
    [ "/persist/data/step-ca" ];

  sops.secrets = {
    "int-acme-ca/kloenk-acme.key.pem".owner = "step-ca";
    "int-acme-ca/intermediate-ca-passphrase".owner = "step-ca";
  };
}
