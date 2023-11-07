{ config, pkgs, lib, ... }:

let 
  links = config.systemd.network.links;
  netdevs = config.systemd.network.netdevs;
  networks = config.systemd.network.networks;
in
{
  systemd.network = {
    links."10-eth0" = {
        matchConfig.MACAddress = "96:00:02:ae:9b:77";
        linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [
        { addressConfig.Address = "2a01:4f8:c012:b874::/64"; }
      ];
      routes = [
        { routeConfig.Gateway = "fe80::1"; }
      ];
      DHCP = "ipv4";
    };
  };
}