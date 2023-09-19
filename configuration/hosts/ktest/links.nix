{ ... }:

{
  systemd.network = {
    networks."20-enp0s1" = {
      name = "enp0s1";
      DHCP = "no";
      addresses = [{ addressConfig.Address = "192.168.64.101/24"; }];
      routes = [{
        routeConfig.Gateway = "192.168.64.1";
      }];
    };

    networks."20-lo" = {
      name = "lo";
      DHCP = "no";
      addresses = [
        { addressConfig.Address = "127.0.0.1/32"; }
        { addressConfig.Address = "127.0.0.53/32"; }
        { addressConfig.Address = "::1/128"; }
      ];
    };
  };
}