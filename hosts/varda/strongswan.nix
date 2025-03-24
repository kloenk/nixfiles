{ config, pkgs, ... }:
let certDirectory = config.security.acme.certs.vpn.directory;
in {
  #imports = [ ../../profiles/strongswan.nix ];

  k.strongswan = {
    enable = true;
    acme.enable = true;
    babel = {
      enable = true;
      public = true;
      id = {
        v4 = 1;
        v6 = "5662";
      };
      bird.extraConfig = ''
        function net_buw() {
          if net.type = NET_IP4 then return net ~ [ 132.195.0.0/21+, 132.195.0.0/16+ ];
          return false;
        }
        protocol direct direct_buw {
          interface "lo";
          interface "buw0";
          # has no v6
          ipv4 {
            table babel4;
            import filter {
              if net_buw() then accept;
              reject;
            };
          };
        }
        protocol direct direct_wg0 {
          interface "wg0";
          ipv6 {
            table babel6;
            import filter {
              if net_wg() then accept;
              reject;
            };
          };
          ipv4 {
            table babel4;
            import filter {
              if net_wg() then accept;
              reject;
            };
          };
        }
      '';
    };
  };

  services.strongswan-swanctl.swanctl = {
    pools = {
      dyn_pool4 = {
        addrs = "10.84.35.20-10.84.35.220";
        subnet = [ "10.84.32.0/22" ];
      };
    };
    connections.dynamic = {
      pools = [ "dyn_pool4" ];
      send_cert = "always";
      local.varda = {
        auth = "pubkey";
        certs = [ config.k.strongswan.cert ];
        id = config.k.strongswan.id;
      };
      remote.roadwarrior = {
        auth = "pubkey";
        ca_id = "vpn.kloenk.dev";
      };
      children.roadwarrior = { local_ts = [ "10.84.32.0/22" ]; };
    };
  };

  systemd.network.networks."40-lo" = {
    addresses = [{ Address = "10.84.35.1/32"; }];
    routes = [
      #{ Destination = "10.84.35.0/24"; }
    ];
  };

  #networking.firewall.extraForwardRules = ''
  #  iifname "gre-*" accept;
  #'';
}
