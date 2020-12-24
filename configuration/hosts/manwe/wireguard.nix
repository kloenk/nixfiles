{ config, lib, ... }:

{
  networking.firewall.allowedUDPPorts = [
    51822 # usee0
  ];

  systemd.network.netdevs."30-usee0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "usee0";
    };
    wireguardConfig = {
      ListenPort = 51822;
      PrivateKeyFile = config.krops.secrets.files."usee0.key".path;
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
      routeConfig.Destination = "192.168.56.0/23";
    }];
  };
}
