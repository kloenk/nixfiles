{ lib, config, ... }:

let
  inherit (lib) mkOption mkEnableOption mkIf types;

  cfg = config.k.wg;

in {
  options.k.wg = {
    enable = mkEnableOption "Enable basic wireguard";
    net = mkEnableOption "net domains" // { default = cfg.enable; };
    public = mkEnableOption "Public Reachable";

    id = mkOption { type = types.int; };

    ipv4 = mkOption {
      type = types.str;
      default = "192.168.242.${toString cfg.id}";
    };
    ipv6 = mkOption {
      type = types.str;
      default = "2a01:4f8:c013:1a4b:ecba::${toString cfg.id}";
    };
  };

  config = mkIf cfg.enable {
    systemd.network = {
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
            PersistentKeepalive = 21;
          }; # // (mkIf (!cfg.public) { PersistentKeepalive = 21; });
        }];
      };
      networks."30-wg0" = {
        name = "wg0";
        linkConfig.RequiredForOnline = "no";
        addresses = [
          { addressConfig.Address = "${cfg.ipv4}/24"; }
          { addressConfig.Address = "${cfg.ipv6}/80"; }
        ];
        routes = [
          { routeConfig.Destination = "192.168.242.0/24"; }
          { routeConfig.Destination = "2a01:4f8:c013:1a4b:ecba::1/80"; }
        ];
      };
    };

    sops.secrets."wireguard/wg0".owner = "systemd-network";
  };
}
