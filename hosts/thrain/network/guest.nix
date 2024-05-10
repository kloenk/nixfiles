{ ... }:

{
  systemd.network = {
    netdevs."40-guest" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "guest";
      };
      vlanConfig.Id = 45;
    };
    networks."40-guest" = {
      name = "guest";
      DHCP = "no";
      addresses = [{ addressConfig.Address = "192.168.45.1/24"; }];
    };

    networks."20-br0".vlan = [ "guest" ];
  };

  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "guest" ];
    subnet4 = [{
      interface = "guest";
      pools = [{ pool = "192.168.45.50 - 192.168.45.150"; }];
      subnet = "192.168.45.0/24";
      option-data = [
        {
          name = "routers";
          data = "192.168.45.1";
        }
        {
          name = "domain-name-servers";
          data = "192.168.45.1";
        }
      ];
    }];
  };
}
