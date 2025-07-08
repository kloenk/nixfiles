{ ... }:

{
  systemd.network = {
    networks."10-lan1".vlan = [ "gwp-desk.1" "gwp-desk.2" "gwp-oob" ];

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

    netdevs."30-gwp-desk-2" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "gwp-desk.2";
      };
      vlanConfig.Id = 1102;
    };
    networks."30-gwp-desk-2" = {
      matchConfig = {
        Type = "vlan";
        Name = "gwp-desk.2";
      };
      DHCP = "no";
      bridge = [ "gwp-br0" ];
    };

    netdevs."30-gwp-oob" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "gwp-oob";
      };
      vlanConfig.Id = 1199;
    };
    networks."30-gwp-oob" = {
      matchConfig = {
        Type = "vlan";
        Name = "gwp-oob";
      };
      DHCP = "no";
      addresses = [ { Address = "10.1.50.1/24"; } { Address = "fe80::1/64"; } ];
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
