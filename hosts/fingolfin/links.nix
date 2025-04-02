{ config, ... }:

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
        v4 = 4;
        v6 = "61f5";
      };
    };
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "96:00:03:c7:60:64";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [{ Address = "2a01:4f8:1c1b:d442::1/64"; }];
      routes = [{ Gateway = "fe80::1"; }];
      DHCP = "ipv4";
    };

    networks."55-gre-varda".routes = [{ Destination = "37.120.162.160"; }];
    networks."40-lo" = {
      addresses = [
        { Address = "192.168.242.4/32"; }
        { Address = "2a01:4f8:c013:1a4b:ecba::4/128"; }
      ];
    };
  };
}
