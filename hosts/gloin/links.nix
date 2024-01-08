{ config, pkgs, lib, ... }:

let
  links = config.systemd.network.links;
  netdevs = config.systemd.network.netdevs;
  networks = config.systemd.network.networks;
in {
  k.wg = {
    enable = true;
    id = 205;
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "84:a9:38:c6:b3:cd";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "yes";
    };

    networks."70-wlan0" = {
      name = "wlan0";
      DHCP = "yes";
    };

    networks."65-home" = {
      matchConfig.SSID = [ "'The Prancing Pony'" "TT-WLAN" ];
      dns = [ "192.168.178.248" ];
      DHCP = "ipv6";
      addresses = [{ addressConfig.Address = "192.168.178.246/24"; }];
      routes = [{ routeConfig.Gateway = "192.168.178.1"; }];
    };

    wait-online.anyInterface = true;
  };
}
