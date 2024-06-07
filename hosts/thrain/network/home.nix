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
    }];
  };
}
