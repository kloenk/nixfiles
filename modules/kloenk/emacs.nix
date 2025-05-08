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

    extraPackages = mkOption {
      type = types.functionTo (types.listOf types.package);
      default = self: [ ];
    };
    extraPackageLiterals = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    k.emacs.package = lib.mkDefault (if cfg.gui then
      if cfg.macports then pkgs.emacs-macport else pkgs.emacs-pgtk
    else
      pkgs.emacs-nox);

    home-manager.users.kloenk = {
      programs.emacs = {
        enable = true;
        package = cfg.package;
        extraPackages = let
          configFor = (pkgs.emacs-config.override {
            emacs = cfg.package;
          }).passthru.configFor;
        in epkgs:
        [ (configFor epkgs) ] ++ (cfg.extraPackages epkgs)
        ++ (map (v: epkgs.${v}) cfg.extraPackageLiterals);
        extraConfig = cfg.extraConfig;
      };
    };

    environment.variables.EDITOR = "emacs -nw";
  };
}
