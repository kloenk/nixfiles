{ pkgs, lib, config, ... }:

let
  cfg = config.programs.nushell;

  configFile = writeConfigFile "config.nu" ''
    let configJson = (open -r ${jsonConfigFile} | from json)
    let-env config = $configJson
    $env.config.hooks.display_output = {||
      if (term size).columns >= 100 { table -e } else { table }
    }
    $env.config.hooks.command_not_found = {||
      null
    }

    let-env NU_LIB_DIRS = (open -r ${
      jsonFormater.generate "nuLibsDirs" cfg.dirs.libs
    } | from json)
    let-env NU_PLUGIN_DIRS = (open -r ${
      jsonFormater.generate "nuPluginsDirs" cfg.dirs.plugins
    } | from json)

    ${cfg.extraConfig}
  '';
  envConfigFile = writeConfigFile "env-config.nu" cfg.env-config;

  inherit (lib) mkEnableOption mkOption types;

  jsonFormater = pkgs.formats.json { };
  jsonConfigFile = jsonFormater.generate "nuJsonConfig" cfg.config;

  writeConfigFile = name: text:
    pkgs.runCommandLocal name {
      inherit text;
      passAsFile = [ "text" ];
      nativeBuildInputs = [ cfg.pkg ] ++ cfg.nativeCheckInputs;
    } # sh
    ''
      nu -c "source $textPath"
      cat $textPath > $out
    '';
in {
  options = {
    programs.nushell = {
      enable = mkEnableOption "Nu shell";

      pkg = mkOption {
        type = types.package;
        default = pkgs.nushell;
      };

      wrapper = mkOption {
        type = types.package;
        default = pkgs.writeShellApplication {
          name = "nu";
          text = ''
            ${cfg.pkg}/bin/nu --config ${configFile} --env-config ${envConfigFile} "$@"
          '';
        } // {
          passthru = { shellPath = "/bin/nu"; };
        };
      };

      nativeCheckInputs = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };

      config = mkOption {
        type = types.attrs;
        default = builtins.fromJSON (builtins.readFile ./config.json);
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };

      env-config = mkOption {
        type = types.lines;
        default = builtins.readFile ./env.nu;
      };

      dirs = {
        plugins = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        libs = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
      };

    };
  };

  config =
    lib.mkIf cfg.enable { environment.systemPackages = [ cfg.wrapper ]; };
}
