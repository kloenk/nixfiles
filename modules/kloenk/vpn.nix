{ lib, config, ... }:

let
  inherit (lib) mkOption mkEnableOption types;
  #inherit (lib) mkIf mkDefault;

  cfg = config.k.vpn;
in {
  options.k.vpn = {
    enable = mkEnableOption "VPN things";
    net = {
      enable = mkEnableOption "net domain" // { default = cfg.enable; };
    };
    monitoring = {
      enable = mkEnableOption "Monitoring" // { default = cfg.net.enable; };
      mobile = mkEnableOption "client is mobile";
      extraAllowRanges = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };
}
