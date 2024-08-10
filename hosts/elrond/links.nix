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
      dns = [ "10.84.16.1" ];
      domains = [ "isengard.home.kloenk.de" "net.kloenk.de" "kloenk.de" ];
      vlan = [ "mgmt" "gwp" ];
      addresses = [{ Address = "10.84.19.1/20"; }];
      routes = [ { Gateway = "10.84.16.1"; } { Gateway = "fe80::1"; } ];

      #  { Gateway = "fd00::ca0e:14ff:fe07:a2fa"; }
      #  ];
    };

    networks."25-tun" = {
      name = "tap*";
      DHCP = "yes";

      linkConfig.RequiredForOnline = "no";
    };

    netdevs."30-mgmt" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "mgmt";
      };
      vlanConfig.Id = 44;
    };
    networks."30-mgmt" = {
      name = "mgmt";
      DHCP = "no";
      addresses = [{ Address = "192.168.44.102/24"; }];
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

    networks."20-lo" = {
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
