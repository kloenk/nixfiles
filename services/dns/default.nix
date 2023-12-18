{ inputs, config, lib, pkgs, ... }:

let
  bbb_wass_zone = pkgs.writeText "bbb.zone"
    (builtins.readFile (toString ./zones/bbb-wass.zone));

  eu_kloenk_zone =
    (import ./zones/eu.kloenk.nix { inherit lib inputs config; });
  dev_kloenk_zone =
    (import ./zones/dev.kloenk.nix { inherit lib inputs config; });
  dev_sysbadge_zone = "${pkgs.kloenk-zoneFiles}/sysbadge.dev";
  #(import ./zones/dev.sysbadge.nix { inherit lib inputs config; });
  dev_matrixcore_zone =
    (import ./zones/dev.matrixcore.nix { inherit lib inputs config; });
  de_kloenk_zone =
    (import ./zones/de.kloenk.nix { inherit lib inputs config; });
  de_p3tr1ch0rr_zone =
    (import ./zones/de.p3tr1ch0rr.nix { inherit lib inputs config; });

  he_secondary =
    "159.69.179.160 51.254.249.185 51.254.249.182 216.218.133.2 2001:470:600::2 5.45.100.14 164.132.31.112";
in {
  # running bind/coredn
  services.resolved.enable = false;

  networking.nameservers = [
    "2001:470:20::2"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
    "1.1.1.1"
  ];

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  # TODO: dnssec

  services.coredns = {
    enable = true;
    config = ''
      (log) {
        prometheus
        errors
      }

      (acl) {
        acl {
          allow net 192.168.242.0/24 195.39.221.0/24 127.0.0.1/8 ::1/128
          block
        }
      }

      (he_transfer) {
        transfer {
          to *
          to ${he_secondary}
          to 192.168.242.101
        }
      }

      . {
        health
        import log
        import acl
        forward . tls://1.1.1.1 tls://1.0.0.1
      }

      uni-wuppertal.de {
        import acl
        forward . dns://132.195.249.13 dns://132.195.20.13
      }

      vpn.uni-wuppertal.de {
        import acl
        forward . tls://1.1.1.1 tls://1.0.0.1
      }

      version.bind version.server authors.bind hostname.bind id.server {
        import acl
        import log
        log
        chaos CoreDNS hostmaster@kloenk.de
      }

      kloenk.eu {
        import log
        file ${eu_kloenk_zone}
        import he_transfer
      }

      kloenk.dev {
        import log
        file ${dev_kloenk_zone}
        import he_transfer
      }

      sysbadge.dev {
        import log
        file ${dev_sysbadge_zone}
        import he_transfer
      }

      matrixcore.dev {
        import log
        file ${dev_matrixcore_zone}
        import he_transfer
      }

      kloenk.de {
        import log
        file ${de_kloenk_zone}
        import he_transfer
      }

      p3tr1ch0rr.de {
        import log
        file ${de_p3tr1ch0rr_zone}
        import he_transfer
      }

      bbb.wass-er.com {
        import log
        file ${bbb_wass_zone}
        import he_transfer
      }

      calli0pa.de {
        import log
        secondary {
          transfer from 87.79.92.36
        }
      }
    '';
  };
}
