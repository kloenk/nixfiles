{ ... }:

{
  k.wg.public = true;

  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "96:00:02:b4:f1:e6";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      addresses = [
        { Address = "2a01:4f8:c013:1a4b::1/64"; }
        { Address = "2a01:4f8:c013:1a4b::/64"; } # TODO: remove
      ];
      routes = [{
        Gateway = "fe80::1";
        Source = "2a01:4f8:c013:1a4b::1";
      }];
      dns = [ "127.0.0.1" ];
      DHCP = "ipv4";
    };
  };
}
