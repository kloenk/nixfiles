{ config, lib, ... }:

{
  networking.firewall.allowedUDPPorts = [
    51820 # wg0
  ];

  systemd.network.netdevs."30-wg0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
    };
    wireguardConfig = {
      ListenPort = 51820;
      PrivateKeyFile = config.petabyte.secrets."wg0.key".path;
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
    addresses = [ { addressConfig.Address = "192.168.242.104/24"; } ];
    routes = [{
      routeConfig.Destination = "192.168.242.0/24";
    }];
  };

  users.users.systemd-network.extraGroups = [ "keys" ];
  petabyte.secrets."wg0.key".owner = "systemd-network";
}
