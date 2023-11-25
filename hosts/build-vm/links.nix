{ config, pkgs, lib, ... }:

let
  links = config.systemd.network.links;
  netdevs = config.systemd.network.netdevs;
  networks = config.systemd.network.networks;
in {
  services.openssh.ports = [ 22 ];

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "e2:f0:e6:81:dd:c5";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [{
        addressConfig.Address = "2a02:3103:63:b800:e0f0:e6ff:fe81:ddc5/64";
      }];
      # routes = [{ routeConfig.Gateway = "fe80::2e91:abff:fe5a:c5d3"; }];
      DHCP = "yes";
    };
  };
}
