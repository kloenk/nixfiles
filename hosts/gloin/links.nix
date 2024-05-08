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

    netdevs."20-dhcp0" = {
      netdevConfig = {
        Kind = "veth";
        Name = "dhcp0";
      };
      peerConfig.Name = "dhcp1";
    };
    networks."20-dhcp0" = {
      name = "dhcp0";
      addresses = [{ addressConfig.Address = "192.168.45.1/24"; }];
    };
    networks."20-dhcp1" = { name = "dhcp1"; };

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
        wireguardPeerConfig = {
          AllowedIPs = [ "0.0.0.0/0" "::/0" ];
          PublicKey = "ZVayNyJeOn848aus5bqYU2ujNxvnYtV3ACoerLtDpg8=";
          Endpoint = "gateway.seven.secunet.com:51821";
        };
      }];
    };
    networks."30-secunet0" = {
      name = "secunet0";
      linkConfig.RequiredForOnline = "no";
      addresses = [
        { addressConfig.Address = "198.18.1.108/15"; }
        { addressConfig.Address = "fd00:5ec::16c/48"; }
      ];
    };

    wait-online.anyInterface = true;
  };

  sops.secrets."secunet/wireguard/secunet0".owner = "systemd-network";
}
