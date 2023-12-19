{ dns, lib, common, ... }:

with dns.combinators; {
  inherit (common.hosts.varda) A AAAA;
  inherit (common.records) CAA SOA NS;

  TXT =
    [ "google-site-verification=Zi_9C2hSucoEJhLD78ijxMaybtjscN0D3t5TNpoeg6Y" ];

  subdomains = rec {
    inherit (common.hosts) varda gimli;

    ns1 = gimli;

    matrix = gimli // { subdomains.api = gimli; };
    uptime = varda;

    net.subdomains = common.net;

    _github-pages-challenge-Kloenk.TXT = [ "93721bf4d3b9ab1d6af40409424d90" ];
  };
}
