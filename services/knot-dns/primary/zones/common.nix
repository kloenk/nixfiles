{ dns, lib, email ? "ca@kloenk.de", ... }:

let
  inherit (dns.combinators) ttl a aaaa;

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
in {
  mail = {
    mxKloenk = with dns.combinators.mx;
      map (dns.combinators.ttl 3600) [
        (mx 10 "gimli.kloenk.de.")
        #secondary (20)
      ];
    dmarcKloenk = with dns.combinators;
      [ (txt "v=DMARC1;p=reject;pct=100;rua=mailto:postmaster@kloenk.de") ];
    spfKloenk = with dns.combinators.spf;
      map (dns.combinators.ttl 600) [
        (strict [
          "a:gimli.kloenk.de"
          "ip4:49.12.72.200/32"
          "ip6:2a01:4f8:c012:b874::/128"
        ])
      ];
  };

  # Hosts
  hosts = {
    varda = hostTTL 1200 "168.119.57.172" "2a01:4f8:c013:1a4b::";
    gimli = hostTTL 1200 "49.12.72.200" "2a01:4f8:c012:b874::";
  };

  # wireguard net
  net = {
    varda = hostTTL 600 "192.168.242.1" "2a01:4f8:c013:1a4b:ecba::1";
    gimli = hostTTL 600 "192.168.242.2" "2a01:4f8:c013:1a4b:ecba::2";
    thrain = hostTTL 600 "192.168.242.101" "2a01:4f8:c013:1a4b:ecba::101";
    frodo = hostTTL 600 "192.168.242.201" "2a01:4f8:c013:1a4b:ecba::201";
    elrond = hostTTL 600 "192.168.242.202" "2a01:4f8:c013:1a4b:ecba::202";
  };

  records = {
    CAA = dns.combinators.letsEncrypt email;

    NS = [ "ns1.kloenk.de." "ns2.kloenk.de." "ns2.leona.is." "ns3.leona.is." ];

    SOA = ((ttl 600) {
      nameServer = "ns1.kloenk.de.";
      adminEmail = "noc.kloenk.de";
      serial = 2023121910;
      refresh = 1800;
      expire = 3600;
      minimum = 600;
    });
  };

  helpers = { inherit hostTTL; };
}
