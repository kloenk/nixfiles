{ ... }:

{
  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "br0" ];
    subnet4 = [{
      id = 1;
      interface = "br0";
      pools = [{ pool = "192.168.178.20 - 192.168.178.220"; }];
      subnet = "192.168.178.0/24";

      option-data = [
        {
          name = "routers";
          data = "192.168.178.1";
        }
        {
          name = "domain-name-servers";
          data = "192.168.178.248";
        }
        {
          name = "domain-name";
          data = "burscheid.home.kloenk.de.";
        }
      ];

      reservations = [
        { # nas
          hw-address = "90:09:D0:0A:12:E7";
          ip-address = "192.168.178.144";
        }
        { # eib
          hw-address = "00:E0:4B:2C:F5:FA";
          ip-address = "192.168.178.44";
        }
        { # pi-star
          hw-address = "2a:70:69:30:dd:33";
          ip-address = "192.168.178.115";
        }
      ];
    }];
  };
}
