{ dns, common, ... }:

with dns.combinators;
let inherit (common.helpers) host;
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

  subdomains = rec {
    "fritz.box" = host {
      ttl = 1800;
      v4 = "192.168.178.1";
    };

    elrond = host { v4 = "192.168.178.247"; };

    thrain = host {
      ttl = 1800;
      v4 = "192.168.178.248";
    };

    ns1 = thrain;
  };
}
