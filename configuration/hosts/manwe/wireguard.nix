{ config, lib, ... }:

{
  networking.firewall.allowedUDPPorts = [
    51822 # usee0
    51820 # wg0
  ];

  systemd.network.netdevs."30-usee0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "usee0";
    };
    wireguardConfig = {
      ListenPort = 51822;
      PrivateKeyFile = config.sops.secrets."wireguard/usee0".path;
    };
    wireguardPeers = [
      { # moodle
        wireguardPeerConfig = {
          AllowedIPs = [ "192.168.56.2/32" ];
          PublicKey = "9Wp/jc6xF4S07zi7K6F9OjhYH8wbFcdQT5U9Dlv50Sc=";
          PersistentKeepalive = 21;
        };
      }
    ];
  };

  systemd.network.networks."30-usee0" = {
    name = "usee0";
    linkConfig = { RequiredForOnline = "no"; };
    addresses = [{addressConfig.Address = "192.168.56.1/24"; }];
    routes = [{
      routeConfig.Destination = "192.168.56.0/24";
    }];
  };

  systemd.network.netdevs."30-wg0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
    };
    wireguardConfig = {
      ListenPort = 51820;
      PrivateKeyFile = config.sops.secrets."wireguard/wg0".path;
    };
    wireguardPeers = [
      { # iluvatar
        wireguardPeerConfig = {
          AllowedIPs = [ "192.168.242.0/24" ];
          PublicKey = "UoIRXpG/EHmDNDhzFPxZS18YBlj9vBQRRQZMCFhonDA=";
          Endpoint = "iluvatar.kloenk.dev:51820";
        };
      }
    ];
  };
  systemd.network.networks."30-wg0" = {
    name = "wg0";
    linkConfig = { RequiredForOnline = "no"; };
    addresses = [ { addressConfig.Address = "192.168.242.103/24"; } ];
    routes = [{
      routeConfig.Destination = "192.168.242.0/24";
    }];
  };

  users.users.systemd-network.extraGroups = [ "keys" ];
  sops.secrets."wireguard/usee0".owner = "systemd-network";
  sops.secrets."wireguard/wg0".owner = "systemd-network";
}
