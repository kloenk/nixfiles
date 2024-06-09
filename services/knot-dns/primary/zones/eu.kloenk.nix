{ dns, lib, common, ... }:

with dns.combinators; {
  inherit (common.hosts.varda) A AAAA SSHFP;
  inherit (common.records) CAA SOA NS;

  TXT =
    [ "google-site-verification=Zi_9C2hSucoEJhLD78ijxMaybtjscN0D3t5TNpoeg6Y" ];

  subdomains = rec {
    inherit (common.hosts) varda vaire gimli;

    ns1 = gimli;

    matrix = gimli // { subdomains.api = gimli; };
    uptime = varda;

    atuin = varda;

    net.subdomains = common.net;

    _github-pages-challenge-Kloenk.TXT = [ "93721bf4d3b9ab1d6af40409424d90" ];
    _discord.TXT = [ "dh=efc22162c3e34ef503539adc6b966740e906deeb" ];
  };
}
