{ ... }:

{
  fileSystems."/var/lib/private/kea" = {
    device = "/persist/data/kea";
    fsType = "none";
    options = [ "bind" ];
  };

  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = false;
          type = "memfile";
        };
        rebind-timer = 2000;
        renew-timer = 1000;
        valid-lifetime = 4000;

        interfaces-config.interfaces = [ "dhcp0" ];
        subnet4 = [{
          pools = [{ pool = "192.168.45.50 - 192.168.45.150"; }];
          subnet = "192.168.45.0/24";
        }];
      };
    };
  };
}
