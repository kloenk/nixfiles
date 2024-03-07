{ config, ... }:

{
  systemd.network = {
    networks."20-ens18" = {
      name = "ens18";
      DHCP = "no";
      dns = [ "1.1.1.1" "2001:4860:4860::8888" ];
      addresses = [
        { addressConfig.Address = "5.9.118.94/32"; }
        { addressConfig.Address = "2a01:4f8:162:6343::4/128"; }
      ];
      routes = [
        {
          routeConfig.Gateway = "5.9.118.73";
          routeConfig.GatewayOnLink = true;
        }
        {
          routeConfig.Gateway = "2a01:4f8:162:6343::2";
          routeConfig.GatewayOnLink = true;
        }
        { routeConfig.Destination = "5.9.118.93"; }
        { routeConfig.Destination = "2a01:4f8:162:6343::3"; }
      ];
    };

    netdevs."30-wgfritz" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wgfritz";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."wireguard/wgfritz".path;
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          AllowedIPs = [ "192.168.178.0/24" ];
          PublicKey = "NUQU5DEFXoyoMRnhhpp7BNdtX2UlEltPlCxrLSAuXV4=";
          PresharedKeyFile = config.sops.secrets."wireguard/wgfritz-psk".path;
          Endpoint = "bvrwkpidtnrnj753.myfritz.net:58675";
          PersistentKeepalive = 21;
        };
      }];
    };
    networks."30-wgfritz" = {
      name = "wgfritz";
      linkConfig.RequiredForOnline = "no";
      addresses = [{ addressConfig.Address = "192.168.178.223/24"; }];
      routes = [{ routeConfig.Destination = "192.168.178.0/24"; }];
    };
  };

  sops.secrets."wireguard/wgfritz".owner = "systemd-network";
  sops.secrets."wireguard/wgfritz-psk".owner = "systemd-network";
}
