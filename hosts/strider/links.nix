{ ... }:

{
  systemd.network = {
    links."10-eth0" = {
      matchConfig.Path = "pci-0000:00:01.0";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "no";
      bridge = [ "br0" ];
    };

    netdevs."20-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
    };
    networks."20-br0" = {
      name = "br0";
      DHCP = "ipv6";
      addresses = [{ Address = "192.168.64.102/24"; }];
      routes = [{ Gateway = "192.168.64.1"; }];
    };

    networks."05-lo" = {
      name = "lo";
      DHCP = "no";
      addresses = [
        { Address = "127.0.0.1/32"; }
        { Address = "127.0.0.53/32"; }
        { Address = "::1/128"; }
      ];
    };
  };
}
