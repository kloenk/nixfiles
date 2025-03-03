{ ... }:

{
  imports = [ ../../profiles/strongswan.nix ];

  services.strongswan-swanctl.swanctl = {
    connections = {
      varda = {
        version = 2;
        remote_addrs = [ "varda.kloenk.dev" ];
        local.default = {
          auth = "pubkey";
          certs = [ "${../../lib/vpn/elros.cert.pem}" ];
          id = "elros.net.kloenk.dev";
        };
        remote.default = { auth = "pubkey"; };
        children = {
          default = {
            local_ts = [ "10.85.0.3/32" "10.84.16.0/22" ];
            remote_ts = [ "10.85.0.0/24" ];

            #mark_in = "0x50C9";
            #mark_out = "0x50C9";

            start_action = "start";
            close_action = "start";
            dpd_action = "restart";
          };
        };
      };

      elrond = {
        version = 2;
        remote_addrs = [ "10.84.19.1" ];
        local_addrs = [ "10.84.16.1" ];
        local.default = {
          auth = "pubkey";
          certs = [ "${../../lib/vpn/elros.cert.pem}" ];
          id = "elros.net.kloenk.dev";
        };
        remote.default = { auth = "pubkey"; };
        children = {
          default = {
            local_ts = [ "10.85.0.3/32" ];
            remote_ts = [ "10.85.0.2/32" ];

            start_action = "trap";
          };
        };
      };
    };
  };

  networking.interfaces.lo.ipv4.addresses = [{
    address = "10.85.0.3";
    prefixLength = 32;
  }];
}
