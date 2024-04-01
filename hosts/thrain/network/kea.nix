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
          persist = true;
          type = "memfile";
        };
        rebind-timer = 2000;
        renew-timer = 1000;
        valid-lifetime = 4000;
      };
    };
  };
}
