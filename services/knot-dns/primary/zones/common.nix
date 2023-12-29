{ dns, lib, email ? "ca@kloenk.de", ... }:

let
  inherit (dns.combinators) ttl a aaaa;

  host = { ttl ? 600, v4 ? null, v6 ? null, sshfp ? null }:
    lib.optionalAttrs (v4 != null) {
      A = [{
        address = v4;
        inherit ttl;
      }];
    } // lib.optionalAttrs (v6 != null) {
      AAAA = [{
        address = v6;
        inherit ttl;
      }];
    } // lib.optionalAttrs (sshfp != null) {
      SSHFP = [{
        algorithm = "ED25519";
        type = "SHA-256";
        fingerprint = sshfp;
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
    varda = host {
      ttl = 1200;
      v4 = "168.119.57.172";
      v6 = "2a01:4f8:c013:1a4b::";
      sshfp =
        "8c0608b28e42f4dabb717a076326ed26c8cdc6309b87509736053a3fe2d6a277";
    };
    gimli = host {
      ttl = 1200;
      v4 = "49.12.72.200";
      v6 = "2a01:4f8:c012:b874::";
      sshfp =
        "3609591c2d5a24edcce7ceb1cf13ee91083071fa5d8be3c8dfc2c412725c8c13";
    };
  };

  # wireguard net
  net = {
    varda = host {
      v4 = "192.168.242.1";
      v6 = "2a01:4f8:c013:1a4b:ecba::1";
      sshfp =
        "8c0608b28e42f4dabb717a076326ed26c8cdc6309b87509736053a3fe2d6a277";
    };
    gimli = host {
      v4 = "192.168.242.2";
      v6 = "2a01:4f8:c013:1a4b:ecba::2";
      sshfp =
        "3609591c2d5a24edcce7ceb1cf13ee91083071fa5d8be3c8dfc2c412725c8c13";
    };
    thrain = host {
      v4 = "192.168.242.101";
      v6 = "2a01:4f8:c013:1a4b:ecba::101";
    };
    frodo = host {
      v4 = "192.168.242.201";
      v6 = "2a01:4f8:c013:1a4b:ecba::201";
    };
    elrond = host {
      v4 = "192.168.242.202";
      v6 = "2a01:4f8:c013:1a4b:ecba::202";
    };
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

  helpers = { inherit host; };
}
