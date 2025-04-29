{ config, ... }:

{
  systemd.network = {
    links."30-wan" = {
      matchConfig.MACAddress = "0a:18:2a:03:25:84";
      linkConfig.Name = "wan";
    };
    networks."30-wan" = {
      name = "wan";
      DHCP = "no";
      networkConfig = { IPv6AcceptRA = false; };
      addresses = [
        { Address = "2a02:8388:8c0:c600::1:28/64"; }
        { Address = "192.168.0.28/24"; }
      ];
      routes = [
        {
          Gateway = "fe80::6a02:b8ff:fe9a:ab24";
          PreferredSource = "2a02:8388:8c0:c600::1:28";
        }
        { Gateway = "192.168.0.1"; }
        {
          Destination = "192.168.0.27";
          Table = "babel";
        }
        {
          Destination = "2a02:8388:8c0:c600::1:27";
          Table = "babel";
          #Source = "2a02:8388:8c0:c600::1:28";
        }
        {
          Destination = "2a02:8388:8c0:c600:68e0:e8fe:ff51:8ca5";
          Table = "babel";
          #Source = "2a02:8388:8c0:c600::1:28";
        }
      ];
    };
  };

  k.strongswan = {
    enable = true;
    acme.enable = true;
    babel = {
      enable = true;
      public = true;
      id = {
        v4 = 119;
        v6 = "bedd";
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall.extraForwardRules = ''
    iifname "gre-*" oifname "wan" accept;
  '';
  networking.nftables.tables = {
    nat = {
      name = "nat";
      family = "inet";
      content = ''
        chain postrouting {
          type nat hook postrouting priority srcnat;

          ip version 4 iifname "gre-*" oifname "wan" masquerade;
          #ip6 version 6 ip6 saddr != ${config.k.strongswan.babel.id.v6-tunnel-ip} iifname "gre-*" oifname "wan" masquerade;
          ip6 version 6 ip6 daddr 2a02:8388:8c0:c600::1:27 iifname "gre-*" oifname "wan" masquerade;
          ip6 version 6 ip6 daddr 2a02:8388:8c0:c600:68e0:e8fe:ff51:8ca5 iifname "gre-*" oifname "wan" masquerade;
        }
      '';
    };
  };
}
