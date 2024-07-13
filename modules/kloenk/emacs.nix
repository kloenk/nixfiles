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
    macports = mkEnableOption "macports" // {
      default = cfg.gui && pkgs.stdenv.isDarwin;
    };

    package = mkOption { type = types.package; };
  };

  config = mkIf cfg.enable {
    k.emacs.package = if cfg.gui then
      if cfg.macports then
        pkgs.emacs-config.override { emacs = pkgs.emacs-macport; }
      else
        pkgs.emacs-config.override { emacs = pkgs.emacs29-pgtk; }
    else
      pkgs.emacs-config.override { emacs = pkgs.emacs-nox; };

    home-manager.users.kloenk = {
      programs.emacs = {
        enable = true;
        package = cfg.package;
      };
    };

    environment.variables.EDITOR = "emacs -nw";
  };
}
