{ config, ... }:

{
  fileSystems."/var/lib/knot" = {
    device = "/persist/data/knot";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  networking.interfaces.lo.ipv4.addresses = [{
    address = "127.0.0.11";
    prefixLength = 8;
  }];

  services.knot = {
    enable = true;
    settings = {
      remote = { internal_ns1 = { address = "fd4c:1796:6b06:5662::53"; }; };
      acl = {
        internal_notify = {
          address = [ "fd4c:1796:6b06:5662::53" ];
          action = "notify";
        };
        internal_transfer = {
          address = [ "fd4c:1796:6b06::/48" "10.84.32.0/22" "127.0.0.0/8" ];
          action = "transfer";
        };
      };
      mod-rrl.default = {
        rate-limit = 200;
        slip = 2;
      };
      template = {
        default = {
          semantic-checks = true;
          global-module = "mod-rrl/default";
        };
        secondary = {
          master = "internal_ns1";
          acl = [ "internal_notify" "internal_transfer" ];
        };
      };
      zone = {
        "kloenk.de".template = "secondary";
        "kloenk.dev".template = "secondary";
        "kloenk.eu".template = "secondary";

        "p3tr1ch0rr.de".template = "secondary";
        "sysbadge.dev".template = "secondary";
      };
    };
  };
}
