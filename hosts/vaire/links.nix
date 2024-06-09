{ ... }:

{
  networking.firewall.allowedUDPPorts = [
    51820 # wg0
  ];

  k.wg = {
    enable = true;
    id = 3;
    public = true;
    mobile = false;
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "96:00:03:65:50:02";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [{ addressConfig.Address = "2a01:4f8:c012:3d74::/64"; }];
      routes = [{ routeConfig.Gateway = "fe80::1"; }];
      DHCP = "ipv4";
    };
  };
}
