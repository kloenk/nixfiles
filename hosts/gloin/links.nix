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
      matchConfig.MACAddress = "84:a9:38:c6:b3:cd";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      # DHCP = "yes";
      bridge = [ "br0" ];
    };

    netdevs."20-br0".netdevConfig = {
      Kind = "bridge";
      Name = "br0";
    };
    networks."20-br0" = {
      name = "br0";
      DHCP = "yes";
    };

    links."10-eth1" = {
      matchConfig.MACAddress = "98:fd:b4:9a:bd:7e";
      linkConfig.Name = "eth1";
    };
    networks."10-eth1" = {
      name = "eth1";
      bridge = [ "br1" ];
      linkConfig.RequiredForOnline = false;
    };

    netdevs."20-br1".netdevConfig = {
      Kind = "bridge";
      Name = "br1";
    };
    networks."20-br1" = {
      name = "br1";
      DHCP = "ipv6";
      vlan = [ "gwp0" ];
      dns = [ "192.168.178.248" ];
      addresses = [{
        Address = "192.168.178.245/24";
        RouteMetric = 1024;
      }];
      routes = [{
        Gateway = "192.168.178.1";
        Metric = 1024;
      }];
    };

    netdevs."30-gwp0" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "gwp0";
      };
      vlanConfig.Id = 1003;
    };
    networks."30-gwp0" = {
      name = "gwp0";
      DHCP = "no";
      bridge = [ "br-gwp" ];
    };

    netdevs."30-br-gwp".netdevConfig = {
      Kind = "bridge";
      Name = "br-gwp";
    };
    networks."30-br-gwp" = {
      name = "br-gwp";
      addresses = [{ Address = "10.1.0.1/24"; }];
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

  sops.secrets."secunet/wireguard/secunet0".owner = "systemd-network";
}
