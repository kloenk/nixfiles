{ lib, config, pkgs, ... }:

let
  inherit (lib) types mkEnableOption mkOption mkIf;

  cfg = config.k.security.pam_u2f;
in {
  options.k.security.pam_u2f = {
    enable = mkEnableOption "Kloenk's pam_u2f module";

    keys = mkOption { type = types.attrsOf (types.listOf types.str); };
  };

  config = mkIf cfg.enable {
    security.pam = {
      u2f = {
        enable = true;
        settings.origin = "pam://kloenk.dev";
        settings.authfile = builtins.toFile "pamu2fcfg" (lib.concatLines
          (lib.mapAttrsToList
            (name: keys: "${name}:${lib.concatStringsSep ":" keys}") cfg.keys));
      };
    };

    services.udev.extraRules = ''
      # Lock when yubikey is removed
      ACTION=="remove", SUBSYSTEM=="hidraw", ENV{ID_SECURITY_TOKEN}=="1", RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    '';
  };
}
