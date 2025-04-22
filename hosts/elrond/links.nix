{ config, pkgs, lib, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  k.wg = {
    enable = true;
    id = 204;
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "00:d8:61:35:91:2f";
      linkConfig.Name = "eth0";
      linkConfig.WakeOnLan = "magic";
    };
    networks."10-eth0" = {
      name = "eth0";
      bond = [ "bond0" ];
      #bridge = [ "br-win" ];
      #DHCP = "ipv4";
      #networkConfig.IPv6AcceptRA = "yes";
      #dhcpV4Config.RouteMetric = 8192;
      #ipv6AcceptRAConfig.RouteMetric = 8192;
      #vlan = [ "mgmt" "gwp" "lan" ];
    };

    links."10-blink0" = {
      matchConfig.MACAddress = "00:02:c9:53:cd:0a";
      linkConfig = {
        Name = "blink0";
        Description = "Blinky cable 0";
      };
    };
    networks."10-blink0" = {
      name = "blink0";
      DHCP = "no";
      networkConfig = {
        Description = "Blinky cable 0";
        PrimarySlave = true;
      };
      bond = [ "bond0" ];
    };

    netdevs."20-bond0" = {
      netdevConfig = {
        Description = "Bond over physical interfaces";
        Kind = "bond";
        Name = "bond0";
      };
      bondConfig = { Mode = "active-backup"; };
    };
    networks."20-bond0" = {
      name = "bond0";
      DHCP = "ipv4";
      networkConfig = {
        Description = "Direct interface, connected to win-ad vlan";
        IPv6AcceptRA = "yes";
      };
      dhcpV4Config.RouteMetric = 8192;
      ipv6AcceptRAConfig.RouteMetric = 8192;
      vlan = [ "mgmt" "gwp" "lan" ];
    };

    netdevs."20-br0" = {
      netdevConfig = {
        Description = "default uplink interface";
        Kind = "bridge";
        Name = "br0";
      };
    };
    networks."20-br0" = {
      name = "br0";
      DHCP = "ipv6";
      networkConfig.Description = "default uplink interface";
      dns = [ "10.84.16.1" "fe80::1" ];
      domains = [ "isengard.home.kloenk.de" "net.kloenk.de" "kloenk.de" ];
      addresses = [{ Address = "10.84.19.1/22"; }];
      routes = [ { Gateway = "10.84.16.1"; } { Gateway = "fe80::1"; } ];
    };

    networks."25-tun" = {
      name = "tap*";
      DHCP = "yes";

      linkConfig.RequiredForOnline = "no";
    };

    netdevs."20-lan" = {
      netdevConfig = {
        Description = "Default lan (vlan 1)";
        Kind = "vlan";
        Name = "lan";
      };
      vlanConfig.Id = 1;
    };
    networks."25-lan" = {
      name = "lan";
      DHCP = "no";
      networkConfig.Description = "Default lan (vlan 1)";
      bridge = [ "br0" ];
    };

    netdevs."30-mgmt" = {
      netdevConfig = {
        Description = "Management vlan";
        Kind = "vlan";
        Name = "mgmt";
      };
      vlanConfig.Id = 51;
    };
    networks."30-mgmt" = {
      name = "mgmt";
      DHCP = "ipv4";
      networkConfig = {
        Description = "Management vlan";
        IPv6AcceptRA = "yes";
      };
      dhcpV4Config = { RouteMetric = 4096; };
      ipv6AcceptRAConfig = { RouteMetric = 4096; };
    };

    netdevs."30-gpw" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "gwp";
      };
      vlanConfig.Id = 1003;
    };
    networks."30-gwp" = {
      name = "gwp";
      DHCP = "no";
      addresses = [{ Address = "10.1.0.2/24"; }];
    };

    networks."40-lo" = {
      name = "lo";
      DHCP = "no";
      addresses = [
        #{ Address = "195.39.246.53/32"; }
        #{ Address = "2a0f:4ac0:f199::3/128"; }
        { Address = "127.0.0.1/32"; }
        { Address = "127.0.0.53/32"; }
        { Address = "::1/128"; }
      ];
    };

    networks."99-whow_cares".linkConfig.RequiredForOnline = "no";
    networks."99-whow_cares".linkConfig.Unmanaged = "yes";
    networks."99-whow_cares".name = "*";
  };

  boot.initrd.systemd.network = {
    links."10-eth0" = config.systemd.network.links."10-eth0";
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "no";
      addresses = config.systemd.network.networks."20-br0".addresses;
    };
  };
}
