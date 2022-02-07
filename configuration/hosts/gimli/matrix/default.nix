{ lib, config, pkgs, ... }:

{
  fileSystems."/var/lib/matrix-synapse" = {
    device = "/persist/data/matrix-synapse";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 8008 ];

  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse";
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
       TEMPLATE template0
       LC_COLLATE = "C"
       LC_CTYPE = "C";
    '';
  };

  services.nginx.virtualHosts."matrix.kloenk.dev" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/_matrix" = {
        proxyPass = "http://127.0.0.1:8008";
      };
      /*"/".root = pkgs.element-web.override {
        conf.default_server_config = {
          "m.homeserver" = {
            base_url = "https://matrix.kloenk.dev";
            server_name = "kloenk.dev";
          };
        };
      };*/
    };
  };


  services.matrix-synapse = {
    enable = true;

    enable_registration = false;
    #registration_shared_secret = "secret";

    server_name = "kloenk.dev";
    public_baseurl = "https://matrix.kloenk.dev:443/";

    database_type = "psycopg2";
    database_args = {
      database = "matrix-synapse";
    };

    listeners = [
      {
        bind_address = "127.0.0.1";
        port = 8008;
        resources = [
          { names = [ "client" ]; compress = true; }
          { names = [ "federation" ]; compress = false; }
        ];
        type = "http";
        tls = false;
        x_forwarded = true;
      }
      {
        bind_address = "192.168.242.104";
        port = 8008;
        resources = [
          { names = [ "client" ]; compress = true; }
          #{ names = [ "federation" ]; compress = false; } # should not be needed, AS should only use client
        ];
        type = "http";
        tls = false;
        x_forwarded = false;
      }
    ];

    app_service_config_files = [
      config.sops.secrets."matrix/exmpp".path
      config.sops.secrets."matrix/exmpp2".path
    ];

    # TODO: `matrix-synapse-shared-secret-auth` for double puppeting?

    extraConfig = ''
      max_upload_size: "100M"
    '';

    url_preview_enabled            = true;
    url_preview_ip_range_blacklist = ["127.0.0.0/8" "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" "100.64.0.0/10" "169.254.0.0/16" "::1/128" "fe80::/64" "fc00::/7"];
  };
  
  sops.secrets."matrix/exmpp".owner = "matrix-synapse";
  sops.secrets."matrix/exmpp2".owner = "matrix-synapse";
  systemd.services.matrix-synapse.serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
}
