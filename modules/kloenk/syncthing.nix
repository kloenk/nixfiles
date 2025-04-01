{ lib, config, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf;

  cfg = config.k.syncthing;

  folderOptions = { name, ... }: {
    options = {
      path = mkOption {
        type = types.str // {
          check = x:
            types.str.check x && (builtins.substring 0 1 x == "/"
              || builtins.substring 0 2 x == "~/");
          description = types.str.description + " starting with / or ~/";
        };
        default = name;
      };
      id = mkOption {
        type = types.str;
        default = name;
      };
      label = mkOption {
        type = types.str;
        default = name;
      };
      devices = mkOption {
        type = types.either (types.enum [ "hosts" ]) (types.listOf types.str);
        default = "hosts";
      };
    };
  };
  folderToSettings = folder:
    folder // {
      devices = if builtins.isList folder.devices then
        folder.devices
      else
        {
          "hosts" =
            lib.mapAttrsToList (name: id: id.id or name) cfg.otherDevices;
        }.${folder.devices};
    };
in {
  options.k.syncthing = {
    enable = mkEnableOption "kloenk syncthing helper";

    devices = mkOption {
      type = types.attrsOf (types.either types.str (types.attrsOf types.str));
      default = { };
      example = { foo = "FULL-SYNCTHING-ID"; };
    };
    otherDevices = mkOption {
      readOnly = true;
      type = types.attrsOf (types.either types.str (types.attrsOf types.str));
      default = lib.filterAttrs (name: _id: name != config.networking.hostName)
        cfg.devices;
    };

    folders = mkOption {
      type = types.attrsOf (types.submodule folderOptions);
      default = { };
    };

    nginx = mkEnableOption "Expose in the internal wg network" // {
      default = config.k.vpn.net.enable;
    };
  };

  config = lib.mkMerge [
    (mkIf cfg.enable {
      services.syncthing = {
        enable = lib.mkDefault true;
        openDefaultPorts = lib.mkDefault true;
        dataDir = lib.mkDefault "/home/kloenk/.syncthing";
        configDir = lib.mkDefault "${config.services.syncthing.dataDir}/conf";
        settings = {
          options.urAccepted = -1;
          devices = lib.mapAttrs (name: id:
            if builtins.isString id then { inherit id name; } else id)
            cfg.otherDevices;
          folders = lib.mapAttrs (name: folderToSettings) cfg.folders;
        };

        user = "kloenk";
        group = "users";
      };

      users.users.kloenk.extraGroups = [ "syncthing" ];

      deployment.tags = [ "syncthing" ];
    })
    (mkIf (cfg.enable && cfg.nginx) {
      services.nginx.virtualHosts."syncthing.${config.networking.hostName}.net.kloenk.de" =
        {
          enableACME = true;
          forceSSL = true;
          kTLS = true;
          extraConfig = ''
            allow 127.0.0.1/8;
            allow ::1/128;
            allow 192.168.242.0/24;
            allow 2a01:4f8:c013:1a4b:ecba::0/80;
            deny all;
          '';
          #listenAddresses = [ config.k.wg.ipv4 "[${config.k.wg.ipv6}]" ];
          locations."/" = {
            recommendedProxySettings = false; # self applied because host header
            extraConfig = ''
              proxy_set_header Host localhost;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Server $host;
            '';
            proxyPass = "http://localhost:8384";
          };

        };

      services.vouch-proxy = {
        enable = true;
        servers."syncthing.${config.networking.hostName}.net.kloenk.de" = {
          clientId = "syncthing";
          port = 57566;
          environmentFiles =
            [ config.sops.secrets."syncthing/vouch_proxy_env".path ];
        };
      };

      sops.secrets."syncthing/vouch_proxy_env" = {
        owner = "root";
        sopsFile = ../../secrets/shared/syncthing.yaml;
      };
    })
  ];
}
