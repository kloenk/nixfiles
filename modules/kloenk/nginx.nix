{ lib, config, ... }:

let
  inherit (lib) mkOption mkEnableOption mkIf types;

  cfg = config.k.nginx;
in {
  options.k.nginx = {
    public = {
      enable = mkEnableOption "enable public file serving" // {
        default = config.k.wg.public;
      };
      domain = mkOption {
        type = types.str;
        default = "${config.networking.hostName}.${config.networking.domain}";
      };
      folder = mkOption {
        type = types.path;
        default = cfg.folder;
      };
    };
    net = {
      enable = mkEnableOption "enable net file serving" // {
        default = config.k.wg.net;
      };
      domain = mkOption {
        type = types.str;
        default = "${config.networking.hostName}.net.kloenk.de";
      };
      folder = mkOption {
        type = types.path;
        default = cfg.folder;
      };
    };
    folder = mkOption {
      type = types.path;
      default = "/persist/data/public";
    };
  };

  config = lib.mkMerge [
    (mkIf cfg.public.enable {
      services.nginx.virtualHosts.${cfg.public.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/public/".alias = cfg.public.folder;
        locations."/public/".extraConfig = "autoindex on;";
      };
    })
    (mkIf cfg.net.enable {
      services.nginx.virtualHosts.${cfg.net.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/public/".alias = cfg.net.folder;
        locations."/public/".extraConfig = "autoindex on;";
      };
      security.acme.certs.${cfg.net.domain}.server =
        "https://acme.net.kloenk.de:8443/acme/acme/directory";
    })
  ];
}
