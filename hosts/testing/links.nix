{ config, pkgs, lib, ... }:

let
  links = config.systemd.network.links;
  netdevs = config.systemd.network.netdevs;
  networks = config.systemd.network.networks;
in {
  networking.firewall.allowedUDPPorts = [
    51820 # wg0
  ];

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "52:54:00:56:6f:24";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "yes";
    };
  };
  boot.initrd.systemd.network = {
    links."10-eth0" = config.systemd.network.links."10-eth0";
    networks."10-eth0" = config.systemd.network.networks."10-eth0";
  };
}
