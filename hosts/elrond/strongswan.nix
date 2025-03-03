{ config, pkgs, ... }:

{
  imports = [ ../../profiles/strongswan.nix ];

  services.strongswan-swanctl = {
    swanctl = {
      connections = {
        varda = {
          version = 2;
          remote_addrs = [ "varda.kloenk.dev" ];
          local.default = {
            auth = "pubkey";
            certs = [ "${../../lib/vpn/elrond.cert.pem}" ];
            id = "elrond.net.kloenk.dev";
          };
          remote.default = {
            auth = "pubkey";
            #id = "varda.net.kloenk.dev";
          };
          children = {
            default = {
              local_ts = [ "10.85.0.2/32" "10.84.19.1/32" ];
              remote_ts = [ "10.85.0.0/24" ];

              start_action = "start";
              close_action = "start";
              dpd_action = "restart";

              hw_offload = "auto";
            };
          };
        };

        elros = {
          version = 2;
          remote_addrs = [ "10.84.16.1" ];
          local_addrs = [ "10.84.19.1" ];
          local.default = {
            auth = "pubkey";
            certs = [ "${../../lib/vpn/elrond.cert.pem}" ];
            id = "elrond.net.kloenk.dev";
          };
          remote.default = { auth = "pubkey"; };
          children = {
            default = {
              local_ts = [ "10.85.0.2/32" ];
              remote_ts = [ "10.85.0.3/32" ];

              start_action = "start";
              close_action = "start";
              dpd_action = "restart";

              hw_offload = "auto";
            };
          };
        };
      };
    };
  };

  #systemd.services.strongswan-swanctl.reloadIfChanged = true;

  systemd.network.networks."05-lo".addresses = [{ Address = "10.85.0.2/32"; }];
}
