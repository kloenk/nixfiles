{ config, pkgs, lib, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  nftables.extraConfig = ''
    table ip nat {
      chain postrouting {
        type nat hook postrouting priority srcnat;
        ip saddr { 192.168.242.0-192.168.242.255 } oifname { "wg0" } snat to 192.168.242.101
        oifname "br0" masquerade
        iifname "wg0" oifname "br0" masquerade
      }
    }
  '';

  systemd.network = {
    networks."20-eno1" = {
      name = "eno1";
      DHCP = "no";
      dns = [ "127.0.0.1" ];
      bridge = [ "br0" ];
      vlan = [ "vlan1337" "mgmt" ];
      /* addresses = [
           { addressConfig.Address = "192.168.178.248/24"; }
           #{ addressConfig.Address = "192.168.178.2/24"; }
         ];
      */
      #routes = [
      #  { routeConfig.Gateway = "192.168.178.1"; }
      #  { routeConfig.Gateway = "fd00::ca0e:14ff:fe07:a2fa"; }
      #];
    };

    netdevs."25-vlan" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan1337";
      };
      vlanConfig.Id = 1337;
    };
    networks."25-vlan" = {
      name = config.systemd.network.netdevs."25-vlan".netdevConfig.Name;
      DHCP = "no";
      addresses = [{ addressConfig.Address = "6.0.2.2/24"; }];
    };
    netdevs."25-mgmt" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "mgmt";
      };
      vlanConfig.Id = 44;
    };
    networks."25-mgmt" = {
      name = config.systemd.network.netdevs."25-mgmt".netdevConfig.Name;
      DHCP = "no";
      addresses = [{ addressConfig.Address = "192.168.44.1/24"; }];
    };

    netdevs."25-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
    };
    networks."25-br0" = {
      name = "br0";
      DHCP = "no";
      addresses = [{
        addressConfig.Address = "192.168.178.248/24";
      }
      #{ addressConfig.Address = "192.168.178.2/24"; }
        ];
      routes = [{
        routeConfig.Gateway = "192.168.178.1";
      }
      #  { routeConfig.Gateway = "fd00::ca0e:14ff:fe07:a2fa"; }
        ];
    };

    networks."25-tun" = {
      name = "tap*";
      DHCP = "yes";

      linkConfig.RequiredForOnline = "no";
    };

    networks."20-lo" = {
      name = "lo";
      DHCP = "no";
      addresses = [
        #{ addressConfig.Address = "195.39.246.53/32"; }
        #{ addressConfig.Address = "2a0f:4ac0:f199::3/128"; }
        { addressConfig.Address = "127.0.0.1/32"; }
        { addressConfig.Address = "::1/128"; }
      ];
    };

    netdevs."30-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        FirewallMark = 51820;
        PrivateKeyFile = config.sops.secrets."wireguard/wg0".path;
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          AllowedIPs = [ "0.0.0.0/0" "::/0" ];
          PublicKey = "UoIRXpG/EHmDNDhzFPxZS18YBlj9vBQRRQZMCFhonDA=";
          PersistentKeepalive = 21;
          Endpoint = "iluvatar.kloenk.dev:51820";
        };
      }];
    };
    networks."30-wg0" = {
      name = "wg0";
      linkConfig = { RequiredForOnline = "yes"; };
      addresses = [{ addressConfig.Address = "192.168.242.101/24"; }];
      routes = [{ routeConfig.Destination = "192.168.242.0/24"; }];
    };

    networks."99-how_cares".linkConfig.RequiredForOnline = "no";
    networks."99-how_cares".linkConfig.Unmanaged = "yes";
    networks."99-how_cares".name = "*";
  };

  sops.secrets."wireguard/wg0".owner = "systemd-network";
  users.users.systemd-network.extraGroups = [ "keys" ];
}
