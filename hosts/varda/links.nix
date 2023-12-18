{ config, pkgs, lib, ... }:

let
  links = config.systemd.network.links;
  netdevs = config.systemd.network.netdevs;
  networks = config.systemd.network.networks;
in {
  k.dns = {
    ipv4 = "168.119.57.172";
    ipv6 = "2a01:4f8:c013:1a4b::";
    public = true;
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "96:00:02:b4:f1:e6";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [{ addressConfig.Address = "2a01:4f8:c013:1a4b::/64"; }];
      routes = [{ routeConfig.Gateway = "fe80::1"; }];
      DHCP = "ipv4";
    };
  };
}
