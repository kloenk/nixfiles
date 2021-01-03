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
      nameServer = "ns1.kloenk.dev.";
      adminEmail = "hostmaster.kloenk.de."; # TODO: change mail
      serial = 2021010103;
      refresh = 3600;
      expire = 604800;
      minimum = 600;
    });

    NS = [ "ns2.he.net." "ns4.he.net." "ns3.he.net." "ns5.he.net." ];

    A = map (ttl 600) [ (a "195.39.247.6") ];

    AAAA = map (ttl 600) [ (aaaa "2a0f:4ac0::6") ];

    TXT = spfKloenk;
    MX = mxKloenk;
    CAA = letsEncrypt config.security.acme.email;

    subdomains = rec {
      iluvatar = hostTTL 1200 "195.39.247.6" "2a0f:4ac0::6";
      manwe = hostTTL 1200 "195.39.221.187" null;
      gimli.CNAME = [ "gimli.wolfsburg.petabyte.dev." ];
      sauron = hostTTL 1200 "195.39.221.54" "2a0f:4ac4:42:0:f199::1";
      aule = hostTTL 1200 "89.163.230.234" null;

      usee-nschl = hostTTL 1200 "5.9.118.93" "2a01:4f8:162:6343::3";

      ns1 = iluvatar;

      git = iluvatar;
      cache = iluvatar;

      _dmarc.TXT = dmarc;

      bitwarden = iluvatar;

      pleroma = manwe;

      grafana = manwe;
      prometheus = manwe;
      alertmanager = manwe;

      matrix = gimli;
      stream = gimli;
      mail = gimli;

    };
  };

in
  dns.writeZone "kloenk.dev" zone
