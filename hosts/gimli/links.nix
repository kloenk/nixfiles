{ config, pkgs, lib, ... }:

let
  v6 = "2a01:4f8:c012:b874::1";
  v4 = "168.119.57.172";

  wgv6 = "2a01:4f8:c013:1a4b:ecba::2";
  wgv4 = "192.168.242.2";
in {
  networking.firewall.allowedUDPPorts = [
    51820 # wg0
  ];

  k.wg = {
    enable = true;
    id = 2;
    public = true;
    mobile = false;
  };

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "96:00:02:ae:9b:77";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [{ Address = "${v6}/64"; }];
      routes = [{ Gateway = "fe80::1"; }];
      DHCP = "ipv4";
    };
  };

  k.strongswan = {
    enable = true;
    acme.enable = true;
    babel = {
      enable = true;
      public = true;
      id = {
        v4 = 2;
        v6 = "11b8";
      };
    };
  };

  systemd.network.networks."40-lo" = {
    addresses = [
      { Address = "192.168.242.2/32"; }
      { Address = "2a01:4f8:c013:1a4b:ecba::2/128"; }
    ];
  };
  systemd.network.netdevs."30-wg0".enable = false;
}
