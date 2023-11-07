{ inputs, config, lib, ... }:

let
  dns = inputs.dns.lib.${config.nixpkgs.system}.dns;

  zone = with dns.combinators; {
    SOA = ((ttl 600) {
      nameServer = "ns1.kloenk.de.";
      adminEmail = "hostmaster@kloenk.de";
      serial = 2023092500;
      refresh = 600;
      expire = 604800;
      minimum = 600;
    });

    NS =
      [ "ns1.he.net." "ns2.he.net." "ns4.he.net." "ns3.he.net." "ns5.he.net." ];

    A = map (ttl 600) [
      (a "185.199.108.153")
      (a "185.199.109.153")
      (a "185.199.110.153")
      (a "185.199.111.153")
    ];
    AAAA = map (ttl 600) [
      (aaaa "2606:50c0:8000::153")
      (aaaa "2606:50c0:8001::153")
      (aaaa "2606:50c0:8002::153")
      (aaaa "2606:50c0:8003::153")
    ];

    subdomains = rec {
      www.CNAME = [ "sysbadge.github.io." ];

      _github-pages-challenge-SysBadge-org.TXT = [ "d6f90acfda" ];
    };
  };
in dns.writeZone "sysbadge.dev" zone
