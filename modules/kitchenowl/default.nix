{ lib, config, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;

  cfg = config.services.kitchenowl;
in {
  options.services.kitchenowl = {
    enable =
      mkEnableOption "Kitchenowl self-hosted grocery list and recipe manager";

    web = {
      enable = mkEnableOption "Kitchenowl web server" // { default = true; };

      package = mkOption {
        type = types.package;
        default = pkgs.kitchenowl-web;
        description = "Kitchenowl web package to use";
      };
    };

    package = mkOption {
      type = types.package;
      default = pkgs.kitchenowl-backend;
      description = "Kitchenowl backend package to use";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/kitchenowl";
      description = "Path for kitchenowl data";
    };

    hostName = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    settings = {
      openRegistration = mkEnableOption "Open registration";
      emailMandatory = mkEnableOption "Email is mandatory";
      collectMetrics = mkEnableOption "collect metrics";

      privacyPolicy = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      db = {
        type = mkOption {
          type = types.enum [ "sqlite" "postgresql" ];
          default = "postgresql";
        };
        name = mkOption {
          type = types.str;
          default = {
            "sqlite" = "${cfg.dataDir}/backend.db";
            "postgresql" = "kitchenowl";
          }.${cfg.settings.db.type};
        };
      };
    };

    extraSettings = mkOption {
      type = types.attrsOf (types.oneOf [ types.str types.int types.path ]);
      default = { };
      description = ''
        Kitchenowl settings. Those are applied via environment variables, so most have to be all upercase.
        See https://docs.kitchenowl.org/self-hosting/advanced/
      '';
    };

    settingsFile = mkOption {
      type = types.either types.path (types.listOf types.path);
      default = [ ];
      description =
        "Files passed via `EnvironmentFile` to the kitchenowl backend service.";
    };

    upgradeDefaultItems = mkEnableOption "Upgrade default items" // {
      default = true;
    };

  };

  config = mkIf cfg.enable {
    services.kitchenowl.extraSettings = lib.mkMerge [
      {
        FRONT_URL = let
          prefix =
            if config.services.nginx.virtualHosts.${cfg.hostName}.forceSSL then
              "https"
            else
              "http";
        in "${prefix}://${cfg.hostName}";

        OPEN_REGISTRATION = lib.boolToString cfg.settings.openRegistration;
        EMAIL_MANDATORY = lib.boolToString cfg.settings.emailMandatory;
        COLLECT_METRICS = lib.boolToString cfg.settings.collectMetrics;

        DB_DRIVER = cfg.settings.db.type;
        DB_NAME = cfg.settings.db.name;
      }
      (mkIf (cfg.settings.privacyPolicy != null) {
        PRIVACY_POLICY_URL = cfg.settings.privacyPolicy;
      })
    ];

    # TODO: non default user
    services.postgresql = mkIf (cfg.settings.db.type == "postgresql") {
      enable = true;
      ensureDatabases = [ "kitchenowl" ];
      ensureUsers = [{
        name = "kitchenowl";
        ensureDBOwnership = true;
      }];
    };

    systemd.services.kitchenowl-backend = {
      description = "Kitchenowl grocey list and recipe manager";
      wantedBy = [ "default.target" ];
      # TODO: Requires/after psql if psql
      environment = cfg.extraSettings // {
        PYTHONPATH = cfg.package.pythonPath;
        STORAGE_PATH = cfg.dataDir;
        NLTK_DATA = pkgs.symlinkJoin {
          name = "kitchenowl-nltk-data";
          paths = cfg.package.nltkData;
        };
      };
      serviceConfig = {
        Type = "notify";
        EnvironmentFile = if builtins.isList cfg.settingsFile then
          cfg.settingsFile
        else
          [ cfg.settingsFile ];
        User = "kitchenowl";
        Group = "kitchenowl";
        DynamicUser = true;
        PrivateTmp = true;
        StateDirectory = "kitchenowl";
        ExecStartPre = pkgs.writeShellScript "kitchenowl-pre-start" ''
          mkdir -p ${cfg.dataDir}/upload

          ${cfg.package.python3Packages.python}/bin/python3 -m flask \
            --app ${cfg.package}/opt/kitchenowl/wsgi.py \
            db upgrade \
            --directory ${cfg.package}/opt/kitchenowl/migrations

          ${lib.optionalString cfg.upgradeDefaultItems ''
            echo "Upgrading default items"
            ${cfg.package.python3Packages.python}/bin/python3 ${cfg.package}/opt/kitchenowl/upgrade_default_items.py
          ''}
        '';
        ExecStart = ''
          ${cfg.package.python3Packages.gunicorn}/bin/gunicorn wsgi:app \
            --worker-class gevent \
            --pythonpath ${cfg.package}/opt/kitchenowl
        '';
      };
    };
    systemd.sockets.kitchenowl-backend = {
      wantedBy = [ "sockets.target" ];
      socketConfig.ListenStream = "/run/kitchenowl/gunicorn.socket";
    };

    services.nginx.virtualHosts.${cfg.hostName} = let
      unixPath =
        config.systemd.sockets.kitchenowl-backend.socketConfig.ListenStream;
    in lib.mkMerge [
      {
        locations."/api/".proxyPass = "http://unix:${unixPath}";
        locations."/socket.io/" = {
          proxyWebsockets = true;
          proxyPass = "http://unix:${unixPath}";
        };
      }
      (mkIf cfg.web.enable {
        root = cfg.web.package;
        locations."/" = {
          tryFiles = "$uri $uri/ /index.html";
          extraConfig = ''
            client_max_body_size 32M;
          '';
        };
      })
    ];
  };
}
