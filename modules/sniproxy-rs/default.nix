{ lib, config, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.services.sniproxy-rs;
  jsonFormat = pkgs.formats.json { };
  configFile = config: jsonFormat.generate "sniproxy.yaml" config;

  backendOpts = { ... }: {
    options = {
      address = mkOption {
        type = types.str;
        example = "example.org:443";
        description =
          "Backend address in the <addr>:<port> form. can be either ip or hostname";
      };
      proxy_protocol = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "HAProxy PROXY protocol. null to disable";
      };

      nat46_prefix = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };
  routeOpts = { name, ... }: {
    options = {
      domains = mkOption {
        type = types.listOf types.str;
        default = [ name ];
        description = "List of valid domains for this route (regexp).";
      };

      backend = mkOption {
        type = types.nullOr (types.submodule backendOpts);
        description = "Backend to proxy to";
      };

      alpn_challenge_backend = mkOption {
        type = types.nullOr (types.submodule backendOpts);
        default = null;
        description = "Backend to use if alpn challenge";
      };

      alpn_challenge_bypass_acl = mkOption {
        type = types.bool;
        default = false;
        description =
          "Bypass ACLs for ALPN challenges, if an ALPN challenge backend is used.";
      };

      denied_ranges = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Allow and deny ACLs, containing a list of IP ranges to allow or deny for
          this route. If 'allow' is used, all non-matching addresses are denied.
          A 'deny' rule wins over an 'allow' one and the most specific subnet
          takes precedence.

          Denied IP ranges. If a request matches, it'll be denied.

          For how allowed ranges compare to denied ones, see `allowed_ranges`.
        '';
      };

      allowed_ranges = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Allowed IP ranges. When not used, non-denied requests will pass through,
          otherwise when at least one IP range is in the allowed ranges, all
          non-matching requests are denied.

          If an IP matches both a denied and an allowed IP range, the most
          specific range wins. Otherwise, the denied range wins over the allowed
          one.
        '';
      };
      http_redirect = mkOption {
        type = types.bool;
        default = true;
        description =
          "Redirect HTTP requests comming to `bind_http` and `bind_https` to their HTTPS counterparts";
      };
    };
  };
in {
  options.services.sniproxy-rs = {
    enable = mkEnableOption "sniproxy-rs service";

    package = mkOption {
      type = types.package;
      default = pkgs.sniproxy-rs;
    };

    routes = mkOption {
      type = types.attrsOf (types.submodule routeOpts);
      description = "routes to server";
    };

    nginx = { proxyHosts = mkEnableOption "" // { default = true; }; };

    settings = {
      bind_https = mkOption {
        type = types.str;
        default = "[::]:443";
        description = "TCP address & port to bind to for the TLS SNI proxy.";
      };
      bind_http = mkOption {
        type = types.str;
        default = "[::1]:8180";
      };

      routes = mkOption {
        type = types.listOf types.attrs;
        internal = true;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {

      services.sniproxy-rs.settings.routes = builtins.attrValues cfg.routes;

      systemd.services."sniproxy-rs" = {
        wantedBy = [ "basic.target" ];
        after = [ "network.target" ];
        description = "SNIproxy rust implementation";
        serviceConfig = {
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          ExecStart =
            "${lib.getExe cfg.package} --config ${configFile cfg.settings}";
          DynamicUser = true;
          User = "sniproxy-rs";
          Group = "sniproxy-rs";

          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
          RestrictNamespaces = true;
        };
      };
    })
    (lib.mkIf (cfg.enable && cfg.nginx.proxyHosts) {
      services.sniproxy-rs.routes."nginxProxies" = {
        domains = let
          filteredNginxHosts =
            lib.filterAttrs (name: _value: name != "localhost")
            config.services.nginx.virtualHosts;
          nginxSmallHosts = lib.mapAttrs (name: value: {
            inherit (value) serverAliases;
            serverName =
              if value.serverName != null then value.servername else name;
          }) filteredNginxHosts;
          nginxCombinedNames = lib.mapAttrs
            (_name: value: [ value.serverName ] ++ value.serverAliases)
            nginxSmallHosts;
        in lib.flatten (builtins.attrValues nginxCombinedNames);
        backend = {
          address = "[::1]:443";
          nat46_prefix = "fe80::ffff:0:0%lo/96";
        };
      };

      services.nginx.defaultListen = [
        {
          addr = "0.0.0.0";
          port = 80;
          ssl = false;
        }
        {
          addr = "[::]";
          port = 80;
          ssl = false;
        }
        {
          addr = "[::1]";
          port = 443;
          ssl = true;
        }
      ];
    })
  ];
}
