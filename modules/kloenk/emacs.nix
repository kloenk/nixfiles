{ lib, config, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf types;

  cfg = config.k.emacs;
in {
  options.k.emacs = {
    enable = mkEnableOption "kloenk's emacs in homemanager" // {
      default = true;
    };
    gui = mkEnableOption "pgtk";

    package = mkOption { type = types.package; };
  };

  config = mkIf cfg.enable {
    k.emacs.package = if cfg.gui then
      pkgs.kloenk-emacs.override { emacs = pkgs.emacs29-pgtk; }
    else
      pkgs.kloenk-emacs.override { emacs = pkgs.emacs29-nox; };

    home-manager.users.kloenk = {
      home.file = {
        ".emacs.d/init.el".source =
          "${cfg.package.passthru.compiledConfig}/init.elc";
        ".emacs.d/early-init.el".source =
          "${cfg.package.passthru.compiledConfig}/early-init.elc";
      };

      programs.emacs = {
        enable = true;
        package = cfg.package;
      };
    };

    environment.variables.EDITOR = "emacs -nw";
  };
}
