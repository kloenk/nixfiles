{ ... }:

{
  systemd.network = {
    links."10-eth1" = {
      matchConfig.Path = "platform-a41000000.pcie-pci-0004:41:00.0";
      linkConfig.Name = "eth1";
    };
    links."10-eth2" = {
      matchConfig.Path = "platform-a40800000.pcie-pci-0002:21:00.0";
      linkConfig.Name = "eth2";
    };

    networks."10-eth1" = {
      name = "eth1";
      DHCP = "no";
      addresses = [{ Address = "192.168.100.2/24"; }];
    };

    networks."10-eth2" = {
      name = "eth2";
      DHCP = "no";
      bridge = [ "lan" ];
    };
  };
}
