{ config, pkgs, lib, ... }:

let
  links = config.systemd.network.links;
  netdevs = config.systemd.network.netdevs;
  networks = config.systemd.network.networks;
in {
  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "84:a9:38:c6:b3:cd";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      networkConfig = {
        Bond = "bond0";
        PrimarySlave = true;
      };
    };

    networks."20-wlan0" = {
      name = "wlan0";
      networkConfig.Bond = "bond0";
    };

    netdevs."10-bond0" = {
      netdevConfig = {
        Kind = "bond";
        Name = "bond0";
      };
      bondConfig = {
        Mode = "active-backup";
        PrimaryReselectPolicy = "always";
        MIIMonitorSec = "1s";
      };
    };

    networks."10-bond0" = {
      name = "bond0";
      DHCP = "yes";
    };
  };
}
