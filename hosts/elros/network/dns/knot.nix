{ lib, config, ... }:

{
  fileSystems."/var/lib/knot" = {
    device = "/persist/data/knot";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.interfaces.lo.ipv4.addresses = [{
    address = "127.0.0.11";
    prefixLength = 8;
  }];

  services.knot = {
    enable = true;
    settings = {
      server.listen = [ "127.0.0.11@53" ];
      acl = {
        internal_ddns_transfer = {
          address = [ "127.0.0.1" ];
          action = [ "update" "transfer" ];
        };
      };
      template = {
        isengard = {
          semantic-checks = true;
          acl = [ "internal_ddns_transfer" ];
          zonefile-load = "none";
          zonefile-sync = -1;
          journal-content = "all";
        };
      };
      zone = {

      };
    };
  };
}
