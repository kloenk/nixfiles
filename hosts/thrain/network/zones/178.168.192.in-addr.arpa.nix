{ dns, ... }:

with dns.combinators;
let
  ptr = name: { PTR = [{ ptrdname = "${name}.burscheid.home.kloenk.de."; }]; };
in {
  SOA = ((ttl 600)) {
    nameServer = "ns1.burscheid.home.kloenk.de.";
    adminEmail = "noc.kloenk.de";
    serial = 2024051000;
    refresh = 600;
    expire = 600;
    minimum = 300;
  };

  NS = [ "ns1.burscheid.home.kloenk.de." ];

  subdomains = {
    "1" = ptr "fritz.box";
    "247" = ptr "elrond";
    "248" = ptr "thrain";
  };
}
