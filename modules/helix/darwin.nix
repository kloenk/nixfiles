{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;

  cfg = config.programs.helix;
  tomlFormat = pkgs.formats.toml { };
in {
  options.programs.helix =
    import ./options.nix { inherit lib pkgs tomlFormat; };

  config = mkIf cfg.enable {
    environment.systemPackages = if cfg.extraPackages != [ ] then
      [
        (pkgs.symlinkJoin {
          name =
            "${lib.getName cfg.package}-wrapped-${lib.getVersion cfg.package}";
          paths = [ cfg.package ];
          preferLocalBuild = true;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/hx \
              --prefix PATH : ${lib.makeBinPath cfg.extraPackages}
          '';
        })
      ]
    else
      [ cfg.package ];

    environment.variables = mkIf cfg.defaultEditor { EDITOR = "hx"; };

    environment.etc = let
      settings = {
        "helix/config.toml" = mkIf (cfg.settings != { }) {
          source = tomlFormat.generate "helix-config" cfg.settings;
        };
        "helix/languages.toml" = mkIf (cfg.languages != { }) {
          source = tomlFormat.generate "helix-languages-config" cfg.languages;
        };
      };

      themes = (lib.mapAttrs' (n: v:
        lib.nameValuePair "helix/themes/${n}.toml" {
          source = tomlFormat.generate "helix-theme-${n}" v;
        }) cfg.themes);
    in settings // themes;
  };
}
