{ ... }:

{
  k.wg = {
    enable = true;
    id = 151;
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "c6:a5:dd:5d:42:d9";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "yes";
    };

    links."10-br-vpn" = {
      matchConfig.MACAddress = "4a:76:cb:bb:5f:6e";
      linkConfig.Name = "br-vpn";
    };
    networks."10-br-vpn" = {
      name = "br-vpn";
      DHCP = "no";
      addresses = [{ Address = "10.84.32.144/30"; }];
    };

    # disable legacy wg0
    netdevs."30-wg0".enable = false;
  };

  k.strongswan = {
    enable = true;
    cert = ../../lib/vpn/maura.cert.pem;
    sopsKey = "vpn/key.pem";
    babel = {
      enable = true;
      id = {
        v4 = 144;
        v6 = "59b2";
      };
      bird.extraConfig = ''
        protocol direct direct_frodo {
          interface "br-vpn";
          ipv6 {
            table babel6;
            import filter {
              if net_vpn() then accept;
              reject;
            };
          };
          ipv4 {
            table babel4;
            import filter {
              if net_vpn() then accept;
              reject;
            };
          };
        }
      '';
    };
  };
  k.vpn.monitoring.mobile = true;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall.extraForwardRules = ''
    oifname "br-vpn" accept;
    iifname "br-vpn" oifname "gre-*" accept;
  '';
}
