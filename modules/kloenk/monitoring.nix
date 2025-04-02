{ lib, config, ... }:

let
  inherit (lib) mkOption mkEnableOption mkIf types;

  cfg = config.k.monitoring;
in {
  options.k.monitoring = {
    enable = mkEnableOption "Kloenk monitoring module";
    x509_certs = {
      interval = mkOption {
        type = types.str;
        default = "5m";
      };
      vpn = {
        enable = mkEnableOption "Monitor vpn certs" // { default = true; };
        certs = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
      };
      acme = {
        enable = mkEnableOption "Monitor acme certs" // { default = true; };
        certs = mkOption {
          type = types.attrsOf (types.listOf types.path);
          readOnly = true;
          description =
            "acme certs to monitor. collected via the security.acme options";
        };
        extraCerts = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "extra http certs to monitor";
        };
      };
    };
  };

  config = lib.mkMerge [
    {
      k.monitoring.x509_certs.acme.certs = let
        certs = config.security.acme.certs;
        certServers = builtins.foldl' (acc: i:
          acc // {
            ${i.server} = (acc.${i.server} or [ ])
              ++ [ (i.directory + "/fullchain.pem") ];
          }) { } (builtins.attrValues certs);
      in lib.filterAttrs
      (name: _value: (builtins.match "https://.*vpn.kloenk.*" name) != [ ])
      certServers;
    }
    (mkIf (cfg.enable && cfg.x509_certs.acme.enable) {
      services.telegraf.extraConfig.inputs.x509_cert = (lib.mapAttrsToList
        (name: value: {
          sources = value;

          tags = {
            cert_category = "acme";
            cert_source = name;
          };
          interval = cfg.x509_certs.interval;
        }) cfg.x509_certs.acme.certs)
        ++ lib.optional (cfg.x509_certs.acme.extraCerts != [ ]) {
          alias = "x509_cert_acme_manual";
          sources = cfg.x509_certs.acme.extraCerts;

          tags = {
            cert_category = "acme";
            cert_source = "manual";
          };
          interval = cfg.x509_certs.interval;
        };

      users.users.telegraf.extraGroups = [ "acme" "nginx" ];
    })
    (mkIf (cfg.enable && cfg.x509_certs.vpn.enable) {
      services.telegraf.extraConfig.inputs.x509_cert = [{
        alias = "x509_cert_vpn";
        sources = cfg.x509_certs.vpn.certs;

        tags = {
          cert_category = "vpn";
          cert_source = if config.k.strongswan.acme.enable then
            "https://vpn.kloenk.dev/acme/acme/directory"
          else
            "manual";
        };
        interval = cfg.x509_certs.interval;
      }];
    })
    (mkIf (cfg.enable && cfg.x509_certs.vpn.enable
      && config.k.strongswan.acme.enable && !cfg.x509_certs.acme.enable) {
        users.users.telegraf.extraGroups = [ "acme" ];
      })
  ];
}
