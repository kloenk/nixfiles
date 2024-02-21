{ config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf types;

  cfg = config.programs.evremap;
  tomlFormat = pkgs.formats.toml { };
  configFile = tomlFormat.generate "remap.toml" cfg.config;
in {
  options.programs.evremap = {
    enable = mkEnableOption "evremap";

    package = mkOption {
      type = types.package;
      default = pkgs.evremap;
    };

    config = mkOption {
      type = tomlFormat.type;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.evremap = {
      wantedBy = [ "basic.target" ];
      unitConfig = { Restart = "on-failure"; };
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/evremap remap ${configFile}";
        User = "root";
        Group = "input";
        DynamicUser = false;
        PrivateTmp = true;
      };
    };
  };
}
