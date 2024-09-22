{ config, pkgs, lib, ... }:

let
  links = config.systemd.network.links;
  netdevs = config.systemd.network.netdevs;
  networks = config.systemd.network.networks;
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  k.wg = {
    enable = true;
    id = 205;
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig = {
        Path = [ "pci-0000:00:1f.6" ];
        Type = "ether";
      };
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      bridge = [ "br0" ];
    };

    netdevs."20-br0".netdevConfig = {
      Kind = "bridge";
      Name = "br0";
    };
    networks."20-br0" = {
      name = "br0";
      DHCP = "ipv4";
      dhcpV4Config = { RouteMetric = 1024; };
      ipv6AcceptRAConfig = { RouteMetric = 1024; };
    };

    links."10-eth1" = {
      matchConfig = {
        Property = [ "ID_BUS=usb" "ID_SERIAL_SHORT=00154000F" ];
        Type = "ether";
      };
      linkConfig.Name = "eth1";
    };
    networks."10-eth1" = {
      name = "eth1";
      bridge = [ "br1" ];
      vlan = [ "mgmt" ];
      linkConfig.RequiredForOnline = false;
    };

    netdevs."20-br1".netdevConfig = {
      Kind = "bridge";
      Name = "br1";
    };
    networks."20-br1" = {
      name = "br1";
      vlan = [ "gwp0" ];
      dns = [ "10.84.16.1" "fe80::1" ];
      domains = [ "isengard.home.kloenk.de" "net.kloenk.de" "kloenk.de" ];
      addresses = [{
        Address = "10.84.19.2/22";
        RouteMetric = 512;
      }];
      routes = [
        {
          Gateway = "10.84.16.1";
          Metric = 512;
        }
        {
          Gateway = "fe80::1";
          Metric = 512;
        }
      ];
    };

    netdevs."30-mgmt" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "mgmt";
      };
      vlanConfig.Id = 51;
    };
    networks."30-mgmt" = {
      name = "mgmt";
      DHCP = "ipv4";
      networkConfig = { IPv6AcceptRA = "yes"; };
      dhcpV4Config = { RouteMetric = 4096; };
      ipv6AcceptRAConfig = { RouteMetric = 4096; };
    };

    networks."70-wlan0" = {
      name = "wlan0";
      DHCP = "yes";
    };

    networks."65-home" = {
      matchConfig.SSID = [ "'The Prancing Pony'" "TT-WLAN" ];
      dns = [ "192.168.178.248" ];
      DHCP = "ipv6";
      addresses = [{
        Address = "192.168.178.246/24";
        RouteMetric = 2048;
      }];
      routes = [{
        Gateway = "192.168.178.1";
        Metric = 2048;
      }];
    };

    # Secunet wireguard
    netdevs."30-secunet0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "secunet0";
        MTUBytes = "1300";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."secunet/wireguard/secunet0".path;
      };
      wireguardPeers = [{
        AllowedIPs = [ "0.0.0.0/0" "::/0" ];
        PublicKey = "ZVayNyJeOn848aus5bqYU2ujNxvnYtV3ACoerLtDpg8=";
        Endpoint = "gateway.seven.secunet.com:51821";
      }];
    };
    networks."30-secunet0" = {
      name = "secunet0";
      linkConfig.RequiredForOnline = "no";
      addresses =
        [ { Address = "198.18.1.108/15"; } { Address = "fd00:5ec::16c/48"; } ];
    };

    wait-online.anyInterface = true;
  };

  boot.initrd.systemd.network = {
    links."10-eth0" = config.systemd.network.links."10-eth0";
    links."10-eth1" = config.systemd.network.links."10-eth1";
  };

  sops.secrets."secunet/wireguard/secunet0".owner = "systemd-network";
}
