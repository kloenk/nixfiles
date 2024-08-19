{ ... }:

{
  systemd.network = {
    networks."10-eth1".vlan = [ "gwp-desk.1" ];

    netdevs."30-gwp-desk.1.vlan" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "gwp-desk.1.vlan";
      };
      vlanConfig.Id = 1101;
    };
    networks."30-gwp-desk.1.vlan" = {
      matchConfig = {
        Type = "vlan";
        Name = "gwp-desk.1.vlan";
      };
      DHCP = "no";
      bridge = [ "gwp-desk.1" ];
    };
    netdevs."30-gwp-desk.1" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "gwp-desk.1";
      };
    };
    networks."30-gwp-desk.1" = {
      matchConfig = {
        Type = "bridge";
        Name = "gwp-desk.1";
      };
      addresses = [{ Address = "10.1.0.1/24"; }];
    };
  };
}
