{ config, pkgs, ... }:

{
  k.vpn.monitoring.mobile = true;
  k.strongswan = {
    enable = true;
    package = pkgs.strongswanTPM;
    cert = ../../lib/vpn/elrond.cert.pem;
    babel = {
      enable = true;
      id = {
        v4 = 150;
        v6 = "59A1";
      };
    };
  };

  services.strongswan-swanctl.swanctl = {
    connections.babel-elros.remote_addrs = [ "fe80::1%br0" "10.84.16.1" ];
    secrets.token.ak_ecc.handle = "0x81010004";
  };

  systemd.network.networks."40-lo" = {
    addresses = [
      { Address = "192.168.242.204/32"; }
      { Address = "2a01:4f8:c013:1a4b:ecba::204/128"; }
    ];
  };
  systemd.network.netdevs."30-wg0".enable = false;
}

