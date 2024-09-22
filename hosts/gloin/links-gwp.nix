{ ... }:

{
  systemd.network = {
    networks."10-eth1".vlan = [ "gwp-desk.1" ];

    netdevs."30-gwp-desk-1" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "gwp-desk.1";
      };
      vlanConfig.Id = 1101;
    };
    networks."30-gwp-desk-1" = {
      matchConfig = {
        Type = "vlan";
        Name = "gwp-desk.1";
      };
      DHCP = "no";
    };

    netdevs."35-gwp-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "gwp-br0";
      };
    };
    networks."35-gwp-br0" = {
      matchConfig = {
        Name = "gwp-br0";
        Type = "bridge";
      };
      networkConfig = { ConfigureWithoutCarrier = "yes"; };
      addresses = [{ Address = "10.1.0.1/24"; }];
    };
  };
}
