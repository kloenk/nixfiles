{ config, pgks, lib, ... }:

let bondName = "world";
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  /* petabyte.nftables.extraConfig = ''
       table ip nat {
         chain postrouting {
           type nat hook postrouting priority srcnat;
           ip saddr 192.168.178.0/24 oif wlp2s0 masquerade
         }
       }
     '';
     nftables.forwardPolicy = "accept";
  */

  systemd.network = {
    netdevs."25-vlan" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan1337";
      };
      vlanConfig.Id = 1337;
    };

    networks."25-vlan" = {
      name = config.systemd.network.netdevs."25-vlan".netdevConfig.Name;
      DHCP = "no";
      addresses = [{ addressConfig.Address = "6.0.2.4/24"; }];
    };

    netdevs."25-dtag" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "dtag0";
      };
      vlanConfig.Id = 1002;
    };
    networks."25-dtag" = {
      name = config.systemd.network.netdevs."25-dtag".netdevConfig.Name;
      DHCP = "no";
      addresses = [{ addressConfig.Address = "192.168.188.1/24"; }];
    };

    networks."20-eno0" = {
      name = "eno0";
      DHCP = "yes";
      vlan = [ "vlan1337" "dtag0" ];
      #dhcpV4Config.RouteMetric = 512;
      #addresses = [{addressConfig.Address = "192.168.178.1/24";}];
    };
    networks."20-wlp2s0" = {
      name = "wlp2s0";
      DHCP = "yes";
    };
    networks."30-lo" = {
      name = "lo";
      DHCP = "no";
      addresses = [
        { addressConfig.Address = "127.0.0.1/32"; }
        { addressConfig.Address = "127.0.0.53/32"; }
        { addressConfig.Address = "::1/128"; }
      ];
    };
    networks."99-how_cares".linkConfig.RequiredForOnline = "no";
    networks."99-how_cares".linkConfig.Unmanaged = "yes";
  };
}
