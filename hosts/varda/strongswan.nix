{ config, pkgs, ... }:

{
  imports = [ ../../profiles/strongswan.nix ];

  services.strongswan-swanctl = {
    swanctl = {
      connections = {
        elrond = {
          version = 2;
          local.default = {
            auth = "pubkey";
            certs = [ "${../../lib/vpn/varda.cert.pem}" ];
            id = "varda.net.kloenk.dev";
          };
          remote.default = {
            auth = "pubkey";
            #id = "*.net.kloenk.dev";
            #certs = [ "${../../lib/vpn/elrond.cert.pem}" ];
          };
          children.default = {
            local_ts = [ "10.85.0.0/24" ];
            remote_ts = [ "10.85.0.0/24" ];
            #remote_ts = [ "10.85.0.2/32" "10.85.0.3/32" ];
            start_action = "trap";
          };
        };
      };
    };
  };

  #systemd.services.strongswan-swanctl.reloadIfChanged = true;

  networking.interfaces.lo.ipv4.addresses = [{
    address = "10.85.0.1";
    prefixLength = 32;
  }];
}
