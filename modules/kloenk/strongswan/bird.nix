{ lib, config, pkgs, ... }:

let
  inherit (lib) mkOption mkEnableOption mkIf types;

  cfg = config.k.strongswan;

  babelIfaceOpts = { ... }: {
    options = {
      linkType = mkOption {
        type = types.enum [ "wired" "wireless" "tunnel" ];
        default = "wired";
      };
      rxCost = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
    };
  };
in {
  options.k.strongswan = {
    babel.bird = {
      earlyExtraConfig = mkOption {
        type = types.lines;
        default = "";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
      babel = {
        interfaces = mkOption {
          type = types.attrsOf (types.submodule babelIfaceOpts);
          default = { };
        };
        extraConfig = mkOption {
          type = types.lines;
          default = "";
        };
      };
    };
  };

  config = mkIf (cfg.enable && cfg.babel.enable) {
    networking.firewall.interfaces =
      lib.mapAttrs (_: _: { allowedUDPPorts = [ 6696 ]; })
      cfg.babel.bird.babel.interfaces;

    services.bird = {
      enable = true;
      config = ''
        ${cfg.babel.bird.earlyExtraConfig}

        include "${
          pkgs.substituteAll {
            name = "bird-${config.networking.hostName}.conf";

            primaryIP4 = cfg.babel.id.v4-private-ip;

            src = ./bird.conf;
          }
        }";

        ${cfg.babel.bird.extraConfig}
      '' + ''
        protocol babel babel_igp {
          ipv4 {
            table babel4;

            import all;
            export all;
          };
          ipv6 {
            table babel6;

            import all;
            export all;
          };
          ${
            lib.concatStringsSep "\n" (lib.mapAttrsToList (name: iface: ''
              interface "${name}" {
                type ${iface.linkType};
                hello interval 500ms;
                update interval 10s;
                ${
                  lib.optionalString (iface.rxCost != null)
                  "rxcost ${toString iface.rxCost};"
                }
                ${iface.extraConfig}
              };
            '') cfg.babel.bird.babel.interfaces)
          }
        }
      '' + ''
        protocol kernel kernel_babel_igp_ipv6 {
          kernel table 440;
          learn;
          ipv6 {
            table babel6;
            import all;
            export filter {
              if net_default() then reject;
              accept;
            };
          };
        }
        protocol kernel kernel_babel_igp_ipv4 {
          kernel table 440;
          learn;
          ipv4 {
            table babel4;
            import all;
            export filter {
              if net_default() then reject;
              accept;
            };
          };
        }
      '';
    };
  };

}
