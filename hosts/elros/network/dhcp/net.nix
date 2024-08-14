{ ... }:

{
  services.radvd.config = ''
    interface eth2 {
      AdvSendAdvert on;
      prefix ::/64 { };
      RDNSS fe80::1 { };
      DNSSL isengard.home.kloenk.de { };
    };
  '';

  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "eth2" ];
    subnet4 = [{
      id = 1;
      interface = "eth2";
      pools = [{ pool = "10.84.16.20 - 10.84.17.220"; }];
      subnet = "10.84.16.0/20";

      option-data = [
        {
          name = "routers";
          data = "10.84.16.1";
        }
        {
          name = "domain-name-servers";
          data = "10.84.16.1";
        }
        {
          name = "domain-name";
          data = "isengard.home.kloenk.de";
        }
      ];

      ddns-qualifying-suffix = "isengard.home.kloenk.de";
    }];
  };
}
