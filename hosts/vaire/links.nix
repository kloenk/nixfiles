{ ... }:

{
  networking.firewall.allowedUDPPorts = [
    51820 # wg0
  ];

  k.strongswan = {
    enable = true;
    acme.enable = true;
    babel = {
      enable = true;
      public = true;
      id = {
        v4 = 3;
        v6 = "C8F1";
      };
    };
  };

  systemd.network = {
    networks."40-lo" = {
      addresses = [
        { Address = "192.168.242.3/32"; }
        { Address = "2a01:4f8:c013:1a4b:ecba::3/128"; }
      ];
    };

    links."10-eth0" = {
      matchConfig.MACAddress = "96:00:03:65:50:02";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [{ Address = "2a01:4f8:c012:3d74::1/64"; }];
      routes = [{ Gateway = "fe80::1"; }];
      DHCP = "ipv4";
    };
  };
}
