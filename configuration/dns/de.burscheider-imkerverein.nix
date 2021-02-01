{ inputs, config, lib, ... }:

let
  dns = inputs.dns.lib.${config.nixpkgs.system}.dns;

  mxKloenk = with dns.combinators.mx;
    map (dns.combinators.ttl 3600) [
      (mx 10 "gimli.kloenk.dev.")
      #secondary (20)
    ];
  dmarc = with dns.combinators;
    [ (txt "v=DMARC1;p=reject;pct=100;rua=mailto:postmaster@kloenk.dev") ];
  spfKloenk = with dns.combinators.spf;
    map (dns.combinators.ttl 600) [
      (strict [
        "a:gimli.kloenk.de"
        "ip4:195.39.247.182/32"
        "ip6:2a0f:4ac0:0:1::cb2/128"
      ])
    ];

  hostTTL = ttl: ipv4: ipv6:
    lib.optionalAttrs (ipv4 != null) {
      A = [{
        address = ipv4;
        inherit ttl;
      }];
    } // lib.optionalAttrs (ipv6 != null) {
      AAAA = [{
        address = ipv6;
        inherit ttl;
      }];
    };

  zone = with dns.combinators; {
    SOA = ((ttl 600) {
      nameServer = "ns1.burscheider-imkerverein.de.";
      adminEmail = "hostmaster@burscheider-imkerverein.de";
      serial = 2020122606;
      refresh = 3600;
      expire = 604800;
      minimum = 600;
    });

    NS = [ "ns2.he.net." "ns4.he.net." "ns3.he.net." "ns5.he.net." ];

    A = map (ttl 600) [ (a "195.39.247.182") ];
    AAAA = map (ttl 600) [ (aaaa "2a0f:4ac0:0:1::cb2") ];

    MX = mxKloenk;

    TXT = spfKloenk ++ [ "google-site-verification=nwoA8cdOGh7-8MC9B0WQIE3jP_neM6L9zehMgcSnkxE" ];
    CAA = letsEncrypt config.security.acme.email;

    subdomains = rec {
      iluvatar.CNAME = [ "iluvatar.kloenk.dev" ];
      ns1 = iluvatar;

      _dmarc.TXT = dmarc;

      drachensegler.MX = mxKloenk;
      drachensegler.TXT = spfKloenk;


      _domainkey.subdomains.mail.TXT = [
        (txt ''
          v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJ5QgJzy63zC5f7qwHn3sgVrjDLaoLLX3ZnQNbmNms4+OJxNgBlb9uqTNqCEV9ScUX/2V+6IY2TqdhdWaNBif+agsym2UvNbCpvyZt5UFEJsGFoccNLR4iDkBKr8uplaW7GTBf5sUfbPQ2ens7mKvNEa5BMCXQI5oNa1Q6MKLjxwIDAQABp=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1D9RI1j3LHkeaHgYVHMpESUZLNwXXYPWGL2pyjHpUIV40gtClvd0QnSK7GRshqQ39bkj72M50vn788BAu3PBHHoICpcQOIE8nds3sAj4IqibSD2pDaunYiArsLxfGtxq8/FfnAHVfO9Cq1nm3EtAvr51tn7j7b25uIjhdrI6B5wIDAQAB'')
      ];
    };
  };
in dns.writeZone "burscheider-imkerverein.de" zone
