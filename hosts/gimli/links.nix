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
      matchConfig.MACAddress = "96:00:02:ae:9b:77";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [{ addressConfig.Address = "2a01:4f8:c012:b874::/64"; }];
      routes = [{ routeConfig.Gateway = "fe80::1"; }];
      DHCP = "ipv4";
    };

    netdevs."30-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."wireguard/wg0".path;
        ListenPort = 51820;
      };
      wireguardPeers = [{ # varda
        wireguardPeerConfig = {
          AllowedIPs = [ "0.0.0.0/0" "::/0" ];
          PublicKey = "UoIRXpG/EHmDNDhzFPxZS18YBlj9vBQRRQZMCFhonDA=";
          Endpoint = "varda.kloenk.de:51820";
        };
      }];
    };
    networks."30-wg0" = {
      name = "wg0";
      linkConfig.RequiredForOnline = "no";
      addresses = [
        { addressConfig.Address = "192.168.242.2/24"; }
        { addressConfig.Address = "2a01:4f8:c013:1a4b:ecba::2/80"; }
      ];
      routes = [
        { routeConfig.Destination = "192.168.242.0/24"; }
        { routeConfig.Destination = "2a01:4f8:c013:1a4b:ecba::1/80"; }
      ];
    };
  };

  sops.secrets."wireguard/wg0".owner = "systemd-network";
}
