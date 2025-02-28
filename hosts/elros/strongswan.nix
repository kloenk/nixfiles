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
        children.default = {
          local_ts = [ "10.85.0.0/24" ];
          remote_ts = [ "10.85.0.0/24" ];
          start_action = "trap|start";
        };
      };
    };
  };

  networking.interfaces.lo.ipv4.addresses = [{
    address = "10.85.0.3";
    prefixLength = 32;
  }];
}
