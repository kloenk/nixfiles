{ inputs, lib, pkgs, config, ... }:

let
  dns = inputs.dns.lib;
  dnsutil = inputs.dns.util.${config.nixpkgs.system};
  common = import ./zones/common.nix { inherit dns lib; };
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
  systemd.network.networks."30-wg0".addresses =
    [{ addressConfig.Address = "2a01:4f8:c013:1a4b:ecba::20:53/128"; }];

  services.knot = {
    enable = true;
    keyFiles = [ config.sops.secrets."dns/knot_primary/keys".path ];
    settings = {
      server.listen = [
        "127.0.0.11@53"

        "168.119.57.172@53"
        "2a01:4f8:c013:1a4b::@53"

        "2a01:4f8:c013:1a4b:ecba::20:53@53"
      ];
      remote = {
        internal_ns2 = { address = "2a01:4f8:c013:1a4b:ecba::2"; };
        leona_ns2 = {
          address = "2a02:247a:22e:fd00:1::1";
          key = "kloenk_leona_secondary";
        };
        leona_ns3 = {
          address = "2a01:4f8:c010:1098::1";
          key = "kloenk_leona_secondary";
        };
      };
      acl = {
        internal = {
          address = [ "2a01:4f8:c013:1a4b:ecba::/80" "127.0.0.0/8" ];
          action = "transfer";
        };
        leona_transfer = {
          address = [ "2a02:247a:22e:fd00:1::1" "2a01:4f8:c010:1098::1" ];
          action = "transfer";
          key = "kloenk_leona_secondary";
        };
      };
      mod-rrl.default = {
        rate-limit = 200;
        slip = 2;
      };
      policy.ecdsa256 = {
        algorithm = "ecdsap256sha256";
        ksk-size = 256;
        zsk-size = 256;
        zsk-lifetime = "90d";
        nsec3 = true;
      };
      template = {
        default = {
          semantic-checks = true;
          global-module = "mod-rrl/default";
        };
        primary = {
          notify = [ "internal_ns2" ];
          acl = [ "internal" ];
          zonefile-sync = -1;
          zonefile-load = "difference-no-serial";
          journal-content = "all";
        };
        signedprimary = {
          dnssec-signing = true;
          dnssec-policy = "ecdsa256";
          semantic-checks = true;
          notify = [ "internal_ns2" "leona_ns2" "leona_ns3" ];
          acl = [ "internal" "leona_transfer" ];
          zonefile-sync = -1;
          zonefile-load = "difference-no-serial";
          journal-content = "all";
        };
      };
      zone = {
        "kloenk.de" = {
          file = dnsutil.writeZone "kloenk.de"
            (import ./zones/de.kloenk.nix { inherit dns lib common; });
          template = "signedprimary";
        };
        "kloenk.dev" = {
          file = dnsutil.writeZone "kloenk.dev"
            (import ./zones/dev.kloenk.nix { inherit dns lib common; });
          template = "signedprimary";
        };
        "kloenk.eu" = {
          file = dnsutil.writeZone "kloenk.eu"
            (import ./zones/eu.kloenk.nix { inherit dns lib common; });
          template = "signedprimary";
        };

        "p3tr1ch0rr.de" = {
          file = dnsutil.writeZone "p3tr1ch0rr.de"
            (import ./zones/de.p3tr1ch0rr.nix { inherit dns lib common; });
          template = "signedprimary";
        };
        "sysbadge.dev" = {
          file = dnsutil.writeZone "sysbadge.dev"
            (import ./zones/dev.sysbadge.nix { inherit dns lib common; });
          template = "signedprimary";
        };
      };
    };
  };

  sops.secrets."dns/knot_primary/keys".owner = "knot";
}
