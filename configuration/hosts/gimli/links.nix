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
    networks."20-eth0" = {
      name = "eth0";
      addresses = [
      ];
      DHCP = "ipv4";
    };
  };
}