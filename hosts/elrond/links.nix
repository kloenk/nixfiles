{ config, pkgs, lib, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  nftables.extraConfig = ''
    table ip nat {
      chain postrouting {
        type nat hook postrouting priority srcnat;
        #ip saddr { 192.168.242.0-192.168.242.255 } oifname { "wg0" } snat to 192.168.242.101
        oifname "br0" masquerade
        iifname "wg0" oifname "br0" masquerade
      }
    }
  '';

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
      DHCP = "no";
      dns = [ "192.168.178.248" ];
      vlan = [ "mgmt" ];
      addresses = [{ addressConfig.Address = "192.168.178.247/24"; }];
      routes = [{
        routeConfig.Gateway = "192.168.178.1";
      }
      #  { routeConfig.Gateway = "fd00::ca0e:14ff:fe07:a2fa"; }
        ];
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
      addresses = [{ addressConfig.Address = "192.168.44.102/24"; }];
    };

    networks."20-lo" = {
      name = "lo";
      DHCP = "no";
      addresses = [
        #{ addressConfig.Address = "195.39.246.53/32"; }
        #{ addressConfig.Address = "2a0f:4ac0:f199::3/128"; }
        { addressConfig.Address = "127.0.0.1/32"; }
        { addressConfig.Address = "127.0.0.53/32"; }
        { addressConfig.Address = "::1/128"; }
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
