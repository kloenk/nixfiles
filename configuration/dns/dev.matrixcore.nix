{ inputs, config, lib, ... }:

let
  dns = inputs.dns.lib.${config.nixpkgs.system}.dns;

  mxKloenk = with dns.combinators.mx;
    map (dns.combinators.ttl 3600) [ (mx 10 "gimli.kloenk.dev.") ];
  dmarc = with dns.combinators;
    [ (txt "v=DMARC1;p=reject;pct=100;rua=mailto:postmaster@kloenk.dev") ];
  spfKloenk = with dns.combinators.spf;
    map (dns.combinators.ttl 600) [
      (strict [
        #"a:kloenk.dev"
        #"a:mail.kloenk.dev"
        "a:gimli.kloenk.dev"
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
      nameServer = "ns1.matrixcore.dev.";
      adminEmail = "hostmaster.kloenk.dev."; # TODO: change mail
      serial = 2021010125;
      refresh = 3600;
      expire = 604800;
      minimum = 600;
    });

    NS = [ "ns2.he.net." "ns4.he.net." "ns3.he.net." "ns5.he.net." ];

    /*A = map (ttl 600) [ (a "195.39.247.6") ];

    AAAA = map (ttl 600) [ (aaaa "2a0f:4ac0::6") ];*/
    A = map (ttl 600) [ (a "195.39.247.187") ];
    AAAA = map (ttl 600) [ (aaaa "2a0f:4ac0:0:1::548") ];
    #CNAME = [ "iluvatar.kloenk.dev." ];

    TXT = spfKloenk; #++ [ "google-site-verification=Zi_9C2hSucoEJhLD78ijxMaybtjscN0D3t5TNpoeg6Y" ];
    MX = mxKloenk;
    CAA = letsEncrypt config.security.acme.email;

    subdomains = rec {
      iluvatar.CNAME = [ "iluvatar.wolfsburg.petabyte.dev." ];
      ns1 = iluvatar;

      cgit = iluvatar;

      git.CNAME = iluvatar.CNAME;
      git.MX = mxKloenk;
      git.TXT = spfKloenk;
      git.subdomains._dmarc.TXT = dmarc;

      _dmarc.TXT = dmarc;

      /*grafana = manwe;
      prometheus = manwe;
      alertmanager = manwe;*/

      #matrix = gimli;

      matrix-push.subdomains.dev = iluvatar;
      matrix-push.CNAME = iluvatar.CNAME;

      mx-redir.CNAME = iluvatar.CNAME;

      /*_domainkey.subdomains.mail.TXT = [
        (txt ''
          v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC5KMotmbfWWCLUgFeUc87fO2Heie+Ye1VPELqGhX60br1VyMnhzCc0uR1Hdjt9ts6ykemyIBBHwRa/GfJnyQq+u6nk0v9kDuNs2E3EftcHpYA1E0LCPs5Wl6d2q50IwKt609XiZWok+C/0hnG7gjYTzI6T2a6vhL7hoQfTpLZJCQIDAQAB'')
      ];*/

    };
  };

in
  dns.writeZone "matrixcore.dev" zone
