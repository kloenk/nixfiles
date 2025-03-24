{ self, lib, config, pkgs, ... }:

let
  inherit (lib) mkOption mkEnableOption mkIf types;

  cfg = config.k.strongswan;

  ownName = config.networking.hostName;
  otherHosts = lib.filterAttrs (name: _: name != config.networking.hostName)
    self.nixosConfigurations;
  otherBabelHosts =
    lib.filterAttrs (_name: cfg: cfg.config.k.strongswan.babel.enable)
    otherHosts;
  babelHosts = lib.mapAttrs (_: cfg: cfg.config.k.strongswan) otherBabelHosts;
  # TODO: local overrides for remote host for e.g. local ip connections between hosts
  #babelHosts = {};
in {
  options.k.strongswan = {
    babel = {
      enable = mkEnableOption "babel routing via strongswan";
      public = mkEnableOption "Host is globaly reachable";
      local_addrs = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      remote_addrs = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      id = {
        v4 = mkOption {
          type = types.int;
          description = "v4 address range";
        };
        v6 = mkOption {
          type = types.str;
          description = "v6 prefix";
        };

        v4-private-ip = mkOption {
          type = types.str;
          readOnly = true;
        };
        v6-tunnel-ip = mkOption {
          type = types.str;
          readOnly = true;
        };
        v6-private-ip = mkOption {
          type = types.str;
          readOnly = true;
        };
      };
    };
  };

  config = mkIf (cfg.enable && cfg.babel.enable) {
    k.strongswan.babel = {
      id.v4-private-ip = "10.84.32.${toString cfg.babel.id.v4}";
      id.v6-tunnel-ip = "fd4c:1796:6b05:${cfg.babel.id.v6}::";
      id.v6-private-ip = "fd4c:1796:6b06:${cfg.babel.id.v6}::";
    };

    networking.firewall.extraForwardRules = ''
      iifname "gre-*" oifname "gre-*" accept;
    '';

    services.strongswan-swanctl.swanctl = {
      connections = lib.mapAttrs' (name: remote: {
        name = "babel-${name}";
        value = {
          version = 2;
          local_addrs =
            cfg.babel.local_addrs; # ++ lib.optional cfg.babel.public cfg.id;
          remote_addrs = remote.babel.remote_addrs
            ++ lib.optional remote.babel.public remote.id;
          local.${ownName} = {
            auth = "pubkey";
            certs = let
              fn = {
                "path" = pkgs.copyPathToStore;
                "string" = x: x;
              }.${builtins.typeOf cfg.cert};
            in [ (fn cfg.cert) ];
            id = cfg.id;
          };
          remote.${name} = {
            auth = "pubkey";
            #ca_id = "vpn.kloenk.dev";
            id = remote.id;
          };
          children."babel-${name}" = lib.mkMerge [
            {
              local_ts = [ "${cfg.babel.id.v6-tunnel-ip}/128" ];
              remote_ts = [ "${remote.babel.id.v6-tunnel-ip}/128" ];
            }
            (mkIf remote.babel.public {
              start_action = "start";
              close_action = "start";
              dpd_action = "restart";
            })
          ];
        };
      }) babelHosts;
    };

    /* networking.interfaces.lo.ipv6.addresses = [{
         address = cfg.babel.id.
       }]
    */

    systemd.network = {
      config.routeTables = { babel = 440; };
      netdevs = lib.mapAttrs' (name: remote: {
        name = "55-gre-${name}";
        value = {
          netdevConfig = {
            Kind = "ip6gre";
            Name = "gre-${name}";
          };
          tunnelConfig = {
            Local = cfg.babel.id.v6-tunnel-ip;
            Remote = remote.babel.id.v6-tunnel-ip;
            Independent = true;
          };
        };
      }) babelHosts;
      networks = lib.listToAttrs ((lib.mapAttrsToList (name: remote: {
        name = "55-gre-${name}";
        value = {
          name = "gre-${name}";
          networkConfig = {
            IPv4Forwarding = true;
            IPv6Forwarding = true;
            LinkLocalAddressing = "ipv6";
          };
          linkConfig.RequiredForOnline = "no";
          addresses = [
            #{
            #  Address = "${cfg.babel.id.v6-tunnel-ip}/128";
            #}
            #{ Address = "${cfg.babel.id.v6-private-ip}/48"; }
            { Address = "${cfg.babel.id.v6-private-ip}/64"; }
            {
              Address = "${cfg.babel.id.v4-private-ip}/32";
            }

            # Link local
            { Address = "fe80::${cfg.babel.id.v6}/64"; }
          ];
          routes = [{
            Destination = "${remote.babel.id.v6-tunnel-ip}/128";
            Type = "unreachable";
          }
          #{
          #  Destination = "${remote.babel.id.v6-tunnel-ip}/64";
          #Table = "babel";
          #}
          #{
          #  Destination = "${remote.babel.id.v4-private-ip}/32";
          #Table = "babel";
          #}
            ];
          routingPolicyRules = [{
            Family = "both";
            Table = "babel";
            Priority = 440;
          }];

        };
      }) babelHosts) ++ [{
        name = "40-lo";
        value = {
          addresses = [{ Address = "${cfg.babel.id.v6-tunnel-ip}/128"; }];
        };
      }]);
      /* lib.mapAttrs' (name: remote: {
           name = "55-gre-${name}";
           value = {
             name = "gre-${name}";
             networkConfig = {
               IPv4Forwarding = true;
               IPv6Forwarding = true;
               LinkLocalAddressing = "ipv6";
             };
             linkConfig.RequiredForOnline = "no";
             addresses = [
               #{
               #  Address = "${cfg.babel.id.v6-tunnel-ip}/128";
               #}
               #{ Address = "${cfg.babel.id.v6-private-ip}/48"; }
               { Address = "${cfg.babel.id.v6-private-ip}/64"; }
               { Address = "${cfg.babel.id.v4-private-ip}/32"; }

               # Link local
               { Address = "fe80::${cfg.babel.id.v6}/64"; }
             ];
             routes = [{
               Destination = "${remote.babel.id.v6-tunnel-ip}/128";
               Type = "unreachable";
             }
             #{
             #  Destination = "${remote.babel.id.v6-tunnel-ip}/64";
               #Table = "babel";
             #}
             #{
             #  Destination = "${remote.babel.id.v4-private-ip}/32";
               #Table = "babel";
             #}
               ];
             routingPolicyRules = [{
               Family = "both";
               Table = "babel";
               Priority = 440;
             }];
           };
         }) babelHosts;
      */
    };

    k.strongswan.babel.bird.babel.interfaces = lib.mapAttrs' (name: remote: {
      name = "gre-${name}";
      value = {

      };
    }) babelHosts;
  };
}
