{ config, pkgs, ... }:

{
  imports = [ ../../profiles/strongswan.nix ];

  services.strongswan-swanctl = {
    swanctl = {
      connections = {
        vpn = {
          version = 2;
          local.default = {
            auth = "pubkey";
            certs = [ "${../../lib/vpn/varda.cert.pem}" ];
            id = "varda.net.kloenk.dev";
          };
          remote.default = {
            auth = "pubkey";
            ca_id = "vpn.kloenk.dev";
          };
          children = {
            default = {
              local_ts = [ "10.85.0.0/24" "10.84.16.0/22" ];
              remote_ts = [ "10.85.0.0/24" ];

              hw_offload = "auto";
            };
            isengard = {
              local_ts = [ "10.85.0.0/24" ];
              remote_ts = [ "10.85.0.0/24" "10.84.16.0/22" ];

              hw_offload = "auto";
            };
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
