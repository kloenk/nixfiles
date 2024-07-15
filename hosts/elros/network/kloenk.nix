{ ... }:

{
  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "kloenk0" ];
    subnet4 = [{
      id = 1001;
      interface = "kloenk0";
      pools = [{ pool = "10.84.23.20 - 10.84.23.220"; }];
      subnet = "10.84.0.0/17";

      option-data = [
        {
          name = "routers";
          data = "10.84.23.1";
        }
        {
          name = "domain-name-servers";
          data = "10.84.23.1";
        }
        {
          name = "domain-name";
          data = "isengard.home.kloenk.de";
        }
      ];

      reservations = [

      ];
    }];
  };
}
