{ config, ... }:

{
  networking.firewall.allowedUDPPorts = [
    51820 # wg0
  ];

  k.wg = {
    enable = true;
    id = 4;
    public = true;
    mobile = false;
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "96:00:03:c7:60:64";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [{ Address = "2a01:4f8:1c1b:d442::1/64"; }];
      routes = [{ Gateway = "fe80::1"; }];
      DHCP = "ipv4";
    };

    /* netdevs."30-wgfritz" = {
         netdevConfig = {
           Kind = "wireguard";
           Name = "wgfritz";
         };
         wireguardConfig = {
           PrivateKeyFile = config.sops.secrets."wireguard/wgfritz".path;
         };
         wireguardPeers = [{
           AllowedIPs = [ "192.168.178.0/24" ];
           PublicKey = "NUQU5DEFXoyoMRnhhpp7BNdtX2UlEltPlCxrLSAuXV4=";
           PresharedKeyFile = config.sops.secrets."wireguard/wgfritz-psk".path;
           Endpoint = "bvrwkpidtnrnj753.myfritz.net:58675";
           PersistentKeepalive = 21;
         }];
       };
       networks."30-wgfritz" = {
         name = "wgfritz";
         linkConfig.RequiredForOnline = "no";
         addresses = [{ Address = "192.168.178.223/24"; }];
         routes = [{ Destination = "192.168.178.0/24"; }];
       };
    */

    #networks."30-wg0" = { routes = [{ Destination = "37.120.162.160"; }]; };

    # wg workarounds
    netdevs."30-wg0".enable = false;
    networks."55-gre-varda".routes = [{ Destination = "37.120.162.160"; }];
    networks."40-lo" = {
      addresses = [
        { Address = "192.168.242.4/32"; }
        { Address = "2a01:4f8:c013:1a4b:ecba::4/128"; }
      ];
    };
  };

  #sops.secrets."wireguard/wgfritz".owner = "systemd-network";
  #sops.secrets."wireguard/wgfritz-psk".owner = "systemd-network";

  k.strongswan = {
    enable = true;
    acme.enable = true;
    babel = {
      enable = true;
      public = true;
      id = {
        v4 = 4;
        v6 = "61f5";
      };
    };
  };
}
