{ ... }:

{
  imports = [ ./eth2.nix ];

  fileSystems."/var/lib/private/kea" = {
    device = "/persist/data/kea";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.firewall.interfaces =
    let allowDhcp = { allowedUDPPorts = [ 69 ]; };
    in { eth2 = allowDhcp; };

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

        ddns-replace-client-name = "when-not-present";
        ddns-override-client-update = true;
        ddns-override-no-update = true;
      };
    };

    dhcp-ddns = {
      enable = true;
      settings = {
        ip-address = "127.0.0.11";
        port = 53001;
        dns-server-timeout = 100;
        ncr-protocol = "UDP";
        ncr-format = "JSON";

        control-socket = {
          socket-type = "unix";
          socket-name = "/run/kea/ddns.socket";
        };

        forward-ddns = {
          ddns-domains = [{
            name = "isengard.home.kloenk.de.";
            dns-servers = [{
              hostname = "";
              ip-address = "127.0.0.11";
              port = 53;
            }];
          }];
        };
        reverse-ddns = {
          ddns-domains = [{
            name = "84.10.in-addr.arpa.";
            dns-servers = [{
              hostname = "";
              ip-address = "127.0.0.11";
              port = 53;
            }];
          }];
        };
      };
    };
  };
}
