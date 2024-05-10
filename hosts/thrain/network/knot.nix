{ inputs, lib, config, ... }:

let
  dns = inputs.dns.lib;
  dnsutil = inputs.dns.util.${config.nixpkgs.system};
  common = import ../../../services/knot-dns/primary/zones/common.nix {
    inherit dns lib;
  };
in {
  fileSystems."/var/lib/knot" = {
    device = "/persist/data/knot";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  networking.interfaces.lo.ipv4.addresses = [{
    address = "127.0.0.11";
    prefixLength = 8;
  }];

  services.knot = {
    enable = true;
    settings = {
      server.listen = [ "127.0.0.11@53" "192.168.44.5@53" ];
      acl = {
        internal_ddns_transfer = {
          address = [ "127.0.0.1" ];
          action = [ "update" "transfer" ];
        };
      };
      template = {
        home = {
          semantic-checks = true;
          acl = [ "internal_ddns_transfer" ];
          zonefile-load = "none";
          zonefile-sync = -1;
          journal-content = "all";
        };
      };
      zone = {
        "burscheid.home.kloenk.de" = {
          template = "home";
          file = dnsutil.writeZone "burscheid.home.kloenk.de"
            (import ./zones/de.kloenk.home.burscheid.nix {
              inherit dns common;
            });
        };
        "178.168.192.in-addr.arpa" = {
          template = "home";
          file = dnsutil.writeZone "178.168.192.in-addr.arpa"
            (import ./zones/178.168.192.in-addr.arpa.nix {
              inherit dns common;
            });
        };
      };
    };
  };
}
