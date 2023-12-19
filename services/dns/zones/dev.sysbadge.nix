{ dns, lib, common, ... }:

let
  zone = with dns.combinators; {
    inherit (common.records) CAA SOA NS;

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
