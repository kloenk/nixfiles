{ ... }:

{
  systemd.network = {
    links."30-wan" = {
      matchConfig.MACAddress = builtins.abort "add mac address";
      linkConfig.Name = "wan";
    };
    networks."30-wan" = {
      name = "wan";
      DHCP = "no";
      addresses = [{ Address = "2a02:8388:8c0:c600::1:28/64"; }];
      routes = [{ Gateway = "fe80::6a02:b8ff:fe9a:ab24"; }];
    };
  };

  k.strongswan = {
    enable = true;
    acme.enable = true;
    babel = {
      enable = true;
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
}
