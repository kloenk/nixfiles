{ ... }:

{
  k.wg = {
    enable = true;
    id = 151;
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "c6:a5:dd:5d:42:d9";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "yes";
    };

    # disable legacy wg0
    netdevs."30-wg0".enable = false;
  };

  k.strongswan = {
    enable = true;
    cert = ../../lib/vpn/maura.cert.pem;
    sopsKey = "vpn/key.pem";
    babel = {
      enable = true;
      id = {
        v4 = 151;
        v6 = "59b2";
      };
    };
  };
}
