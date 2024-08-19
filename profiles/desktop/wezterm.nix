{ lib, config, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.k.programs.wezterm;
in {
  options.k.programs.wezterm = {
    font_size = mkOption {
      type = types.float;
      default = 11.0;
    };
  };

  config = {
    home-manager.users.kloenk = {
      programs.wezterm = {
        enable = true;
        colorSchemes = {
          monokai = {
            ansi = [
              "#403E41"
              "#FF6188"
              "#A9DC76"
              "#FFD866"
              "#FC9867"
              "#AB9DF2"
              "#78DCE8"
              "#FCFCFA"
            ];
            brights = [
              "#727072"
              "#FF6188"
              "#A9DC76"
              "#FFD866"
              "#FC9867"
              "#AB9DF2"
              "#78DCE8"
              "#FCFCFA"
            ];
            background = "#2D2A2E";
            #cursor_bg = "#BEAF8A";
            #cursor_border = "#BEAF8A";
            #cursor_fg = "#1B1B1B";
            foreground = "#FCFCFA";
            selection_bg = "#69616B";
            selection_fg = "#FCFCFA";
          };
        };
        extraConfig = ''
          local wezterm = require 'wezterm'
          -- This table will hold the configuration.
          local config = {}
          -- In newer versions of wezterm, use the config_builder which will
          -- help provide clearer error messages
          if wezterm.config_builder then
            config = wezterm.config_builder()
          end
          config.font = wezterm.font("Monaspace Krypton Var", { weight = 'DemiBold' })
          config.font_size = ${toString cfg.font_size}
          config.front_end = "WebGpu"
          config.color_scheme = "monokai"
          config.window_background_opacity = 0.75
          return config
        '';
      };
    };
  };
}
