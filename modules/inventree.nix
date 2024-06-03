{ lib, config, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;

  configFormat = pkgs.formats.json { };
  configFile = configFormat.generate "inventree-config.json" cfg.config;
  cfg = config.services.inventree;
  pkg = cfg.package;

  inventree-invoke = pkgs.writeShellApplication {
    name = "inventree-invoke";
    text = ''
      export INVENTREE_CONFIG_FILE=${configFile}
      export INVENTREE_SECRET_KEY_FILE=${cfg.secretKeyFile}
      export INVENTREE_STATIC_I18_ROOT=${cfg.dataDir}/i18n
      export PYTHONPATH=${pkg.pythonPath}

      exec -a "$0" ${pkgs.python3Packages.invoke}/bin/invoke -r ${cfg.package}/opt/inventree "$@"
    '';
  };
in {
  options.services.inventree = {
    enable = mkEnableOption "InvenTree parts manager";

    package = lib.mkOption {
      type = types.package;
      default = pkgs.inventree;
      description = ''
        InvenTree package to use
      '';
    };

    hostName = mkOption {
      type = types.str;
      description = "FQDN for the InvenTree instance.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/inventree";
      example = "/var/lib/inventree";
      description = ''
        The default path for all inventree data.
      '';
    };

    secretKeyFile = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/secret_key.txt";
      description = ''
        Path to a file containing the secret key
      '';
    };

    /* configPath = mkOption {
         type = types.str;
         default = cfg.dataDir + "/config.yaml";
         description = ''
           Path to config.yaml (automatically created)
         '';
       };
    */

    config = mkOption {
      type = types.submodule ({
        freeformType = configFormat.type;
        options = {
          static_root = mkOption {
            type = types.path;
            default = "${cfg.dataDir}/static";
            description = ''
              Static file storage
            '';
          };
          media_root = mkOption {
            type = types.path;
            default = "${cfg.dataDir}/media_root";
            description = "Media root directory";
          };
          backup_dir = mkOption {
            type = types.path;
            default = "${cfg.dataDir}/backups";
            description = "Backup directory";
          };
        };
      });
      default = { };
      description = ''
        Config options, see https://docs.inventree.org/en/stable/start/config/
        for details
      '';
    };

    serverStartTimeout = mkOption {
      type = types.str;
      # Allow for long migrations to run properly
      default = "10min";
      description = ''
        TimeoutStartSec for the server systemd service.
        See https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#TimeoutStartSec=
        for more details
      '';
    };

    serverStopTimeout = mkOption {
      type = types.str;
      default = "5min";
      description = ''
        TimeoutStopSec for the server systemd service.
        See https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#TimeoutStopSec=
        for more details
      '';
    };

  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ inventree-invoke ];

    # TODO: add other database options
    services.inventree.config = {
      plugins_enabled = false;
      plugin_file = "${cfg.dataDir}/plugins.txt";
      plugin_dir = "${cfg.dataDir}/plugins";
      database = {
        ENGINE = "postgresql";
        NAME = "inventree";
        HOST = "/run/postgresql";
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "inventree" ];
      ensureUsers = [{
        name = "inventree";
        ensureDBOwnership = true;
      }];
    };

    users.users.inventree = {
      group = "inventree";
      # Is this important?
      #uid = config.ids.uids.inventree;
      # Seems to be required with no uid set
      isSystemUser = true;
      description = "InvenTree daemon user";
    };

    users.groups.inventree = { };

    services.nginx.virtualHosts.${cfg.hostName} = {
      locations = let
          unixPath = config.systemd.sockets.inventree-gunicorn.socketConfig.ListenStream;
        in {
        "/" = {
          extraConfig = ''
            client_max_body_size 100M;
          '';
          proxyPass = "http://unix:${unixPath}";
        };
        "/static/" = {
          alias = "${cfg.config.static_root}/";
          extraConfig = ''
            expires 30d;
          '';
        };
        "/media/" = {
          alias = "${cfg.config.media_root}/";
          extraConfig = ''
            auth_request /auth;
          '';
        };
        "/auth" = {
          extraConfig = ''
            internal;
          '';
          proxyPass = "http://unix:${unixPath}:/auth/";
        };
      };
    };

    systemd.targets.inventree = {
      description = "Target for all InvenTree services";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };

    systemd.services.inventree-migrate = {
      description = "InvenTree database migration";
      wantedBy = [ "inventree.target" ];
      partOf = [ "inventree.target" ];
      environment = {
        INVENTREE_CONFIG_FILE = configFile;
        INVENTREE_SECRET_KEY_FILE = cfg.secretKeyFile;
        INVENTREE_STATIC_I18_ROOT = "${cfg.dataDir}/i18n";

        PYTHONPATH = pkg.pythonPath;
      };
      serviceConfig = {
        User = "inventree";
        Group = "inventree";
        StateDirectory = "inventree";
        #RuntimeDirectory = "inventree";
        PrivateTmp = true;
        ExecStart = ''
          ${inventree-invoke}/bin/inventree-invoke migrate
        '';
      };
    };

    systemd.services.inventree-static = {
      description = "InvenTree static migration";
      wantedBy = [ "inventree.target" ];
      partOf = [ "inventree.target" ];
      environment = {
        INVENTREE_CONFIG_FILE = configFile;
        INVENTREE_SECRET_KEY_FILE = cfg.secretKeyFile;
        INVENTREE_STATIC_I18_ROOT = "${cfg.dataDir}/i18n";

        PYTHONPATH = pkg.pythonPath;
      };
      serviceConfig = {
        User = "inventree";
        Group = "inventree";
        StateDirectory = "inventree";
        #RuntimeDirectory = "inventree";
        PrivateTmp = true;
        ExecStart = ''
          ${inventree-invoke}/bin/inventree-invoke static
        '';
      };
    };

    systemd.services.inventree-gunicorn = {
      description = "InvenTree Gunicorn server";
      requiredBy = [ "inventree.target" ];
      after = [ "inventree-migrate.service" ];
      requires = [ "inventree-migrate.service" ];
      partOf = [ "inventree.target" ];
      #wantedBy = [ "inventree.target" ];
      environment = {
        INVENTREE_CONFIG_FILE = configFile;
        INVENTREE_SECRET_KEY_FILE = cfg.secretKeyFile;
        INVENTREE_STATIC_I18_ROOT = "${cfg.dataDir}/i18n";

        PYTHONPATH = pkg.pythonPath;
      };
      serviceConfig = {
        User = "inventree";
        Group = "inventree";
        StateDirectory = "inventree";
        #RuntimeDirectory = "inventree";
        PrivateTmp = true;
        ExecStart = ''
          ${pkg.gunicorn}/bin/gunicorn InvenTree.wsgi \
            --pythonpath ${pkg}/opt/inventree/src/backend/InvenTree
        '';
      };
    };

    systemd.sockets.inventree-gunicorn = {
      wantedBy = [ "sockets.target" ];
      partOf = [ "inventree.target" ];
      socketConfig.ListenStream = "/run/inventree/gunicorn.socket";
    };

    systemd.services.inventree-qcluster = {
      description = "InvenTree qcluster server";
      requiredBy = [ "inventree.target" ];
      after = [ "inventree-migrate.service" ];
      requires = [ "inventree-migrate.service" ];
      wantedBy = [ "inventree.target" ];
      partOf = [ "inventree.target" ];
      environment = {
        INVENTREE_CONFIG_FILE = configFile;
        INVENTREE_SECRET_KEY_FILE = cfg.secretKeyFile;
        INVENTREE_STATIC_I18_ROOT = "${cfg.dataDir}/i18n";

        PYTHONPATH = pkg.pythonPath;
      };
      serviceConfig = {
        User = "inventree";
        Group = "inventree";
        StateDirectory = "inventree";
        #RuntimeDirectory = "inventree";
        PrivateTmp = true;
        ExecStart = ''
          ${pkg}/opt/inventree/src/backend/InvenTree/manage.py qcluster
        '';
      };
    };
  };
}
