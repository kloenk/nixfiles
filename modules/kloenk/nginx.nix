{ lib, config, options, ... }:

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
      default = "/persist/data/public/";
    };
  };

  config = lib.mkMerge [
    (mkIf cfg.public.enable {
      services.nginx.virtualHosts.${cfg.public.domain} = {
        enableACME = true;
        forceSSL = true;
        kTLS = true;
        locations."/public/".alias = cfg.public.folder;
        locations."/public/".extraConfig = "autoindex on;";
      };
    })
    (mkIf cfg.net.enable {
      services.nginx.virtualHosts.${cfg.net.domain} = {
        enableACME = true;
        forceSSL = true;
        kTLS = true;
        locations."/public/".alias = cfg.net.folder;
        locations."/public/".extraConfig = "autoindex on;";
      };
      security.acme.certs = let
        hosts = config.services.nginx.virtualHosts;
        filterdHosts = lib.filterAttrs
          (name: _value: (builtins.match ".*\\.net\\.kloenk\\.de" name) != null)
          hosts;
        filteredHostNames = builtins.attrNames filterdHosts;
      in builtins.listToAttrs (map (name: {
        name = name;
        value.server =
          lib.mkDefault "https://acme.net.kloenk.de:8443/acme/acme/directory";
      }) filteredHostNames);
    })
  ];
}
