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
        "ip4:49.12.72.200/32"
        "ip6:2a01:4f8:c012:b874::/128"
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
      nameServer = "ns1.kloenk.de.";
      adminEmail = "hostmaster@kloenk.de";
      serial = 2020122610;
      refresh = 600;
      expire = 604800;
      minimum = 600;
    });

    NS = [ "ns1.he.net." "ns2.he.net." "ns4.he.net." "ns3.he.net." "ns5.he.net." ];

    #A = map (ttl 600) [ (a "195.39.247.6") ];
    A = map (ttl 600) [ (a "49.12.72.200") ];
    AAAA = map (ttl 600) [ (aaaa "2a01:4f8:c012:b874::") ];

    #AAAA = map (ttl 600) [ (aaaa "2a0f:4ac0::6") ];

    #CNAME = [ "iluvatar.kloenk.dev." ];

    MX = mxKloenk;

    TXT = spfKloenk ++ [];
    CAA = letsEncrypt config.security.acme.email;

    SRV = [];

    subdomains = rec {
      #ns1 = iluvatar;

      _dmarc.TXT = dmarc;

      _domainkey.subdomains.mail.TXT = [
        (txt ''
          v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDeP0+6Zzo+No/So3XAH2+ow7+6B4JyCK4TvLlfxu3OPvFaqom/OvCkQLRJY9bii4Rxw8XECFczvBs9Y+AhfK8miR87Ibg94/9n/jpYzZm7BoyKwZlayA3G62abULw6znEGu+OfKpnoKHIAiJbjlRuZUj/8Z7HsUAFXoPkTJzCEWQIDAQAB'')
      ];
    };
  };
in dns.writeZone "p3tr1ch0rr.de" zone
