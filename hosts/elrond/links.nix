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

  systemd.network = {
    networks."20-enp34s0" = {
      name = "enp34s0";
      DHCP = "no";
      bridge = [ "br0" ];
    };

    netdevs."25-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
    };
    networks."25-br0" = {
      name = "br0";
      DHCP = "no";
      dns = [ "192.168.178.248" ];
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
}
