{ ... }:

{
  k.strongswan = {
    enable = true;
    cert = ../../lib/vpn/elros.cert.pem;
    sopsKey = "vpn/key.pem";
    babel = {
      enable = true;
      id = {
        v4 = 50;
        v6 = "d34d";
      };
    };
  };

  systemd.network.networks."40-lo" = {
    addresses = [
      { Address = "192.168.242.102/32"; }
      { Address = "2a01:4f8:c013:1a4b:ecba::102/128"; }
    ];
  };
}
