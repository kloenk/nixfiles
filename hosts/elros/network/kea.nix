{ config, pkgs, ... }:

{
  fileSystems."/var/lib/private/kea" = {
    device = "/persist/data/kea";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.firewall.interfaces =
    let allowDhcp = { allowedUDPPorts = [ 69 ]; };
    in { lan = allowDhcp; };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "kea" ];
    ensureUsers = [{
      name = "kea";
      ensureDBOwnership = true;
    }];
  };

  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        lease-database = {
          #type = "memfile";
          #name = "/var/lib/kea/leases";
          persist = true;
          type = "postgresql";
          name = "kea";
          host = "/run/postgresql";
          user = "kea";
        };

        host-reservation-identifiers = [ "hw-address" ];
        hosts-database = {
          type = "postgresql";
          name = "kea";
          user = "kea";
          host = "/run/postgresql";
        };

        #dhcp4o6-port = 6767;

        rebind-timer = 2000;
        renew-timer = 1000;
        valid-lifetime = 4000;

        hooks-libraries = [
          { library = "${pkgs.kea}/lib/kea/hooks/libdhcp_bootp.so"; }
          { library = "${pkgs.kea}/lib/kea/hooks/libdhcp_pgsql_cb.so"; }
        ];

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

  systemd.services.kea-dhcp4-server = {
    path = [ config.services.postgresql.package ];
    preStart = ''
      ${pkgs.kea}/bin/kea-admin db-init pgsql -h /run/postgresql -u kea -n kea || true
      ${pkgs.kea}/bin/kea-admin db-upgrade pgsql -h /run/postgresql -u kea -n kea || true
    '';
  };
}
