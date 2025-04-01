{ config, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  k.strongswan = {
    enable = true;
    cert = ../../lib/vpn/thrain.cert.pem;
    sopsKey = "vpn/key.pem";
    babel = {
      enable = true;
      id = {
        v4 = 101;
        v6 = "a4d1";
      };
    };
  };

  systemd.network = {
    # eth0 - physical interface
    links."10-eth0" = {
      matchConfig.MACAddress = "d8:cb:8a:d1:41:43";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "no";
      dns = [ "127.0.0.1" ];
      bridge = [ "br0" ];
    };

    # br0 - bridge
    netdevs."20-br0".netdevConfig = {
      Kind = "bridge";
      Name = "br0";
    };
    networks."20-br0" = {
      name = "br0";
      DHCP = "ipv6";
      vlan = [ "mgmt" ];
      addresses = [{ Address = "192.168.178.248/24"; }];
      routes = [{ Gateway = "192.168.178.1"; }];
    };

    # mgmt - vlan
    netdevs."30-mgmt" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "mgmt";
      };
      vlanConfig.Id = 44;
    };
    networks."30-mgmt" = {
      name = "mgmt";
      DHCP = "no";
      addresses = [{ Address = "192.168.44.5/24"; }];
    };
  };

  # initrd network
  boot.initrd.systemd.network = {
    links."10-eth0" = config.systemd.network.links."10-eth0";
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "no";
      addresses = config.systemd.network.networks."20-br0".addresses;
    };

    netdevs."30-wg-initrd" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg-initrd";
      };
      wireguardConfig = { PrivateKeyFile = "/etc/secrets/30-wg-initrd.key"; };
      wireguardPeers = [{
        AllowedIPs = [ "2a01:4f8:c013:1a4b:ecba:1338::1/120" ];
        PublicKey = "hEcjE8kt3vSYkoWrAr8SaMMq4OkRcRvNJ5GhM78hpW0=";
        Endpoint = "[2a01:4f8:c013:1a4b::1]:51830";
      }];
    };
    networks."30-wg-initrd" = {
      name = "wg-initrd";
      addresses = [{ Address = "2a01:4f8:c013:1a4b:ecba:1338::101/128"; }];
      routes = [{ Destination = "2a01:4f8:c013:1a4b:ecba:1338::1/120"; }];
    };
  };

  sops.secrets."wireguard/wg-initrd".owner = "systemd-network";
  boot.initrd.secrets."/etc/secrets/30-wg-initrd.key" =
    config.sops.secrets."wireguard/wg-initrd".path;
}
