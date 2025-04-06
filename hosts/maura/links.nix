{ ... }:

{
  systemd.network = {
    links."10-eth0" = {
      matchConfig.MACAddress = "c6:a5:dd:5d:42:d9";
      linkConfig.Name = "eth0";
    };
    networks."10-eth0" = {
      name = "eth0";
      DHCP = "yes";
      routes = [{
        Destination = "10.84.34.8/29";
        Table = "babel";
      }];
    };
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
      /* bird.extraConfig = ''
           protocol direct direct_frodo {
             interface "eth0";
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
      */
    };
  };
  k.vpn.monitoring.mobile = true;

  # network overrides
  services.strongswan-swanctl.swanctl = {
    connections.babel-elros.remote_addrs = [ "10.84.16.1" ];
    connections.babel-elrond.remote_addrs = [ "10.84.19.1" ];
  };

  Networking.firewall.extraForwardRules = ''
    oifname "br-vpn" accept;
    iifname "br-vpn" oifname "gre-*" accept;
  '';
}
