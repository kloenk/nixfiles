{ ... }:

{
  fileSystems."/var/lib/private/kea" = {
    device = "/persist/data/kea";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.firewall.allowedUDPPorts = [ 69 ];

  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        authorative = true;
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        rebind-timer = 2000;
        renew-timer = 1000;
        valid-lifetime = 4000;

        dhcp-ddns = {
          enable-updates = true;
          qualifying-suffix = "burscheid.home.kloenk.de.";
          server-ip = "127.0.0.11";
          server-port = 53001;
          ncr-protocol = "UDP";
          ncr-format = "JSON";
        };
        ddns-replace-client-name = "when-not-present";
        ddns-override-client-update = true;
        ddns-override-no-update = true;
        ddns-qualifying-suffix = "burscheid.home.kloenk.de.";

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
            name = "burscheid.home.kloenk.de.";
            dns-servers = [{
              hostname = "";
              ip-address = "127.0.0.11";
              port = 53;
            }];
          }];
        };
        reverse-ddns = {
          ddns-domains = [{
            name = "178.168.192.in-addr.arpa.";
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
