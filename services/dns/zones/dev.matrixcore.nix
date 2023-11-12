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
        "ip4:9.12.72.200/32"
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
      nameServer = "ns1.matrixcore.dev.";
      adminEmail = "hostmaster.kloenk.dev."; # TODO: change mail
      serial = 2021010131;
      refresh = 600;
      expire = 604800;
      minimum = 600;
    });

    NS = [
      "ns1.kloenk.dev."
      "ns1.he.net."
      "ns2.he.net."
      "ns4.he.net."
      "ns3.he.net."
      "ns5.he.net."
    ];

    /* A = map (ttl 600) [ (a "195.39.247.6") ];

       AAAA = map (ttl 600) [ (aaaa "2a0f:4ac0::6") ];
    */
    A = map (ttl 600) [ (a "49.12.72.200") ];
    AAAA = map (ttl 600) [ (aaaa "2a01:4f8:c012:b874::") ];
    #CNAME = [ "iluvatar.kloenk.dev." ];

    TXT = spfKloenk ++ [
      "google-site-verification=HNiDFThpZZWaFE0YH4TzDN2coqiBoedYzj0CxDN6Nl8"
    ];
    MX = mxKloenk;
    CAA = letsEncrypt config.security.acme.email;

    subdomains = rec {
      varda.CNAME = [ "varda.kloenk.dev." ];
      ns1 = varda;

      #cgit = varda;

      #git.CNAME = varda.CNAME;
      git.MX = mxKloenk;
      #git.TXT = spfKloenk;
      git.subdomains._dmarc.TXT = dmarc;

      _dmarc.TXT = dmarc;

      matrix-push.subdomains.dev = varda;
      matrix-push.CNAME = varda.CNAME;

      mx-redir.CNAME = varda.CNAME;

      blog.CNAME = [ "matrixcore.github.io." ];
      _github-challenge-MatrixCore-organization.TXT = [ (txt "c56620a5d1") ];
      blog.subdomains.www.CNAME = [ "blog" ];

      /* _domainkey.subdomains.mail.TXT = [
           (txt ''
             v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC5KMotmbfWWCLUgFeUc87fO2Heie+Ye1VPELqGhX60br1VyMnhzCc0uR1Hdjt9ts6ykemyIBBHwRa/GfJnyQq+u6nk0v9kDuNs2E3EftcHpYA1E0LCPs5Wl6d2q50IwKt609XiZWok+C/0hnG7gjYTzI6T2a6vhL7hoQfTpLZJCQIDAQAB'')
         ];
      */

    };
  };

in dns.writeZone "matrixcore.dev" zone
