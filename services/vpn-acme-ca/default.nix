{ lib, config, ... }:

{
  services.step-ca = {
    enable = true;
    address = "[::1]";
    port = 8443;
    intermediatePasswordFile =
      config.sops.secrets."vpn-acme-ca/key-password".path;
    settings = {
      dnsNames = [ "vpn.kloenk.dev" "::1" ];
      root = [ ../../lib/kloenk-ca.cert.pem ../../lib/kloenk-vpn.cert.pem ];
      crt = ../../lib/kloenk-vpn.cert.pem;
      key = config.sops.secrets."vpn-acme-ca/key.pem".path;
      db = {
        type = "postgresql";
        #dataSource = "";
        database = "step-ca";
      };
      crl = {
        enabled = true;
        generateOnRevoke = true;
      };
      authority = {
        policy = {
          x509 = {
            allow = {
              dns = [ "*.net.kloenk.dev" "*.kloenk.dev" ];
              email = [ "@kloenk.dev" ];
              uri = [ "auth.kloenk.dev" ];
            };
            deny = { email = [ ]; };
          };
        };
        provisioners = [
          {
            type = "OIDC";
            name = "keycloak";
            clientID = "vpn-acme-ca";
            clientSecret = "EZUBifhucfA1hIHwc29jFL61acgdUDoQ";
            configurationEndpoint =
              "https://auth.kloenk.dev/realms/kloenk/.well-known/openid-configuration";
            #admins = [ "auth@kloenk.dev" "kloenk" "8a375fae-4154-47ef-af6d-4bbeb41fb0e1" ];
            claims = {
              maxTLSCertDuration = "8600h";
              defaultTLSCertDuration = "4300h";
            };
            options = {
              x509 = {
                template = ''
                  {
                    "subject": {
                      "country": {{ toJson .country }},
                      "organization": {{ toJson .organization}},
                      "organizationalUnit": {{ toJson .OrganizationalUnit }},
                      "commonName": {{ toJson .Insecure.CR.Subject.CommonName }}
                    },
                    "dnsNames": {{ toJson .Insecure.CR.DNSNames }},
                    "emailAddresses": {{ toJson .Insecure.CR.EmailAddresses }},
                    "uris": {{ toJson .Insecure.CR.URIs }},
                    "extKeyUsage": [ "clientAuth" ]
                  }
                '';
                templateData = {
                  OrganizationalUnit = "vpn";
                  organization = "kloenk";
                  country = "DE";
                };
              };
            };
          }
          {
            type = "ACME";
            name = "acme";
            claims = {
              maxTLSCertDuration = "8600h";
              defaultTLSCertDuration = "4300h";
            };
            options = {
              x509 = {
                template = ''
                  {
                    "subject": {
                      "country": {{ toJson .country }},
                      "organization": {{ toJson .organization}},
                      "organizationalUnit": {{ toJson .OrganizationalUnit }},
                      "commonName": {{ toJson .Insecure.CR.Subject.CommonName }}
                    },
                    "dnsNames": {{ toJson .Insecure.CR.DNSNames }},
                    "emailAddresses": {{ toJson .Insecure.CR.EmailAddresses }},
                    "uris": {{ toJson .Insecure.CR.URIs }},
                    "extKeyUsage": [ "clientAuth" ]
                  }
                '';
                templateData = {
                  OrganizationalUnit = "vpn";
                  organization = "kloenk";
                  country = "DE";
                };
              };
            };
          }
        ];
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [{
      name = "step-ca";
      ensureDBOwnership = true;
    }];
    ensureDatabases = [ "step-ca" ];
  };

  services.nginx = {
    upstreams.vpn-acme-ca = { servers = { "[::1]:8443" = { }; }; };
    virtualHosts."vpn.kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      locations = {
        "/.well-known/security.txt".tryFiles =
          "${../../lib/security.txt.asc} =404";
        "~ /root/" = { proxyPass = "https://vpn-acme-ca"; };
        "/renew" = { proxyPass = "https://vpn-acme-ca/renew"; };
        "/sign" = { proxyPass = "https://vpn-acme-ca/sign"; };
        "/acme" = { proxyPass = "https://vpn-acme-ca/acme"; };
        "/provisioners" = { proxyPass = "https://vpn-acme-ca/provisioners"; };
      };
    };
  };

  sops.secrets = {
    "vpn-acme-ca/key-password".owner = "step-ca";
    "vpn-acme-ca/key.pem".owner = "step-ca";
  };
}
