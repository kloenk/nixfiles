{ config, pkgs, lib, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  k.wg = {
    enable = true;
    id = 101;
  };

  nftables.extraConfig = ''
    table ip nat {
      chain postrouting {
        type nat hook postrouting priority srcnat;
        ip saddr { 192.168.242.0-192.168.242.255 } oifname { "wg0" } snat to 192.168.242.101
        oifname "br0" masquerade
        iifname "wg0" oifname "br0" masquerade
      }
    }
  '';

  systemd.network = {
    # eth0 - physical interface
    links."10-eth0" = {
      matchConfig.MACAddress = "d8:cb:8a:d1:41:43";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "no";
      dns = [ "127.0.0.1" ];
      bridge = [ "br0" ];
    };

    # br0 - bridge
    netdevs."20-br0".netdevConfig = {
      Kind = "bridge";
      Name = "br0";
    };
    networks."20-br0" = {
      name = "br0";
      DHCP = "ipv6";
      vlan = [ "mgmt" ];
      addresses = [{ addressConfig.Address = "192.168.178.248/24"; }];
      routes = [{ routeConfig.Gateway = "192.168.178.1"; }];
    };

    # mgmt - vlan
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
      addresses = [{ addressConfig.Address = "192.168.44.5/24"; }];
    };
  };

  # initrd network
  boot.initrd.systemd.network = {
    links."10-eth0" = config.systemd.network.links."10-eth0";
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "no";
      addresses = config.systemd.network.networks."20-br0".addresses;
    };
  };
}
