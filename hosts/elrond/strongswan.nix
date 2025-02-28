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
          children.default = {
            local_ts = [ "10.85.0.0/24" ];
            remote_ts = [ "10.85.0.0/24" ];
            start_action = "trap|start";
          };
        };
      };
    };
  };

  #systemd.services.strongswan-swanctl.reloadIfChanged = true;

  systemd.network.networks."05-lo".addresses = [{ Address = "10.85.0.2/32"; }];
}
