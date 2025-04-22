{ lib, config, pkgs, ... }:

{
  imports = [
    #./go-neb.nix
    ./heisenbridge.nix
  ];

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

  services.nginx.virtualHosts."matrix.kloenk.eu" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/_matrix" = { proxyPass = "http://127.0.0.1:8008"; };
      "/.well-known/security.txt".tryFiles =
        "${../../lib/security.txt.asc} =404";
    };
  };

  services.matrix-synapse = {
    enable = true;

    #registration_shared_secret = "secret";

    # TODO: `matrix-synapse-shared-secret-auth` for double puppeting?

    extraConfigFiles = [ config.sops.secrets."matrix/config".path ];

    settings = {
      server_name = "kloenk.eu";
      public_baseurl = "https://matrix.kloenk.eu:443/";
      enable_metrics = true;

      enable_registration = false;

      listeners = [
        {
          bind_addresses = [ "127.0.0.1" ];
          port = 8008;
          resources = [
            {
              names = [ "client" ];
              compress = true;
            }
            {
              names = [ "federation" ];
              compress = false;
            }
          ];
          type = "http";
          tls = false;
          x_forwarded = true;
        }
        {
          port = 8009;
          type = "metrics";
          bind_addresses = [ "127.0.0.1" "::1" ];
          resources = [{ names = [ "metrics" ]; }];
          tls = false;
        }
      ];

      database_type = "psycopg2";
      database_args = { database = "matrix-synapse"; };

      extraConfig = ''
        max_upload_size: "100M"
      '';

      app_service_config_files = [
        "/var/lib/heisenbridge/registration.yml"
        #  config.sops.secrets."matrix/exmpp".path
        #  config.sops.secrets."matrix/exmpp2".path
      ];

      url_preview_enabled = true;
      url_preview_ip_range_blacklist = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "100.64.0.0/10"
        "169.254.0.0/16"
        "::1/128"
        "fe80::/64"
        "fc00::/7"
      ];
    };
  };

  services.telegraf.extraConfig.inputs.prometheus = [{
    urls = [ "http://localhost:8009/_synapse/metrics" ];
    tags.index = "1";
  }];

  sops.secrets."matrix/config".owner = "matrix-synapse";

  backups.matrix-synapse = {
    user = "matrix-synapse";
    paths = [ "/persist/data/matrix-synapse" ];
    postgresDatabases = [ "matrix-synapse" ];
  };
}
