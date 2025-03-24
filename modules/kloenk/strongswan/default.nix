{ lib, config, pkgs, ... }:

let
  inherit (lib) mkOption mkEnableOption mkIf types;

  cfg = config.k.strongswan;
in {
  imports = [ ./babel.nix ./bird.nix ];

  options.k.strongswan = {
    enable = mkEnableOption "Strongswan-swanctl common kloenk config";
    openFirewall = mkEnableOption "open firewall part" // { default = true; };
    cert = mkOption {
      type = with types; oneOf [ str path ];
      default = cfg.acme.cert;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.strongswan;
    };
    id = mkOption {
      type = types.str;
      default = "${config.networking.hostName}.kloenk.dev";
      description = "IKE identity";
    };
    sopsKey = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    acme = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description =
          "Use acme to get host certificate. This needs the host to be defined in kloenk.dev";
      };
      id = mkOption {
        type = types.str;
        default = cfg.id;
      };
      cert = mkOption {
        type = types.str;
        readOnly = true;
      };
    };
  };

  config = lib.mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [ cfg.package ];

      networking.firewall.allowedUDPPorts =
        lib.optionals cfg.openFirewall [ 500 4500 ];

      systemd.tmpfiles.rules = [
        "L+ /etc/swanctl/x509ca/ca.cert.pem - - - - ${
          ../../../lib/kloenk-ca.cert.pem
        }"
        "L+ /etc/swanctl/x509ca/vpn.cert.pem - - - - ${
          ../../../lib/kloenk-vpn.cert.pem
        }"
        #"L+ /etc/swanctl/x509ca/vpn.cert.pem - - - - ${../../../lib/kloenk-vpn.cert.pem}"
      ];

      services.strongswan-swanctl = {
        enable = true;
        inherit (cfg) package;
      };

      systemd.network.config = {
        routeTables = { strongswan = 220; };
        networkConfig = {
          ManageForeignRoutingPolicyRules = "no";
          ManageForeignRoutes = "no";
        };
      };
    })
    (mkIf (cfg.sopsKey != null) {
      sops.secrets.${cfg.sopsKey}.owner = "root";
      systemd.tmpfiles.rules = [
        "L+ /etc/swanctl/private/${cfg.id}.pem - - - - ${
          config.sops.secrets.${cfg.sopsKey}.path
        }"
      ];
    })
    (mkIf cfg.acme.enable (let
      acmeCertRoot = config.security.acme.certs."vpn-${cfg.acme.id}".directory;
    in {
      security.acme.certs."vpn-${cfg.acme.id}" = {
        webroot = config.services.nginx.virtualHosts.${cfg.acme.id}.acmeRoot;
        server = "https://vpn.kloenk.dev/acme/acme/directory";
        reloadServices = [ "strongswan-swanctl.service" ];
        domain = cfg.acme.id;
      };

      systemd.tmpfiles.rules = [
        "L+ /etc/swanctl/private/${cfg.acme.id}.pem - - - - ${acmeCertRoot}/key.pem"
        "L+ /etc/swanctl/x509/${cfg.acme.id}.pem - - - - ${acmeCertRoot}/fullchain.pem"
      ];

      #k.strongswan.acme.cert = "${acmeCertRoot}/fullchain.pem";
      k.strongswan.acme.cert = "${cfg.acme.id}.pem";
    }))
  ];
}
