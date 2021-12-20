{ lib, pkgs, config, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf literalExpression;
  cfg = config.services.epmd;
in {
  options = {
    services.epmd = {
      enable = mkEnableOption "Erlang Port Mapper Daemon (epmd), which acts as a name server on all hosts involved in distributed Erlang computations.";

      package = mkOption {
        type = types.package;
        default = pkgs.erlang;
        defaultText = literalExpression "pkgs.erlang";
        description = ''
          The Erlang package to use to get epmd binary. That way you can re-use
          an Erlang runtime that is already installed for other purposes.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    launchd.daemons.epmd = {
      command = "${cfg.package}/bin/epmd";
      serviceConfig.KeepAlive = true;
    };
  };
}