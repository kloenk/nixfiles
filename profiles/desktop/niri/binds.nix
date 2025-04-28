{ pkgs, ... }:

{
  users.users.kloenk.packages = with pkgs; [ fuzzel wezterm ];

  home-manager.users.kloenk = {

    programs.niri = {
      settings = {
        binds = {
          "Mod+Return" = {
            repeat = false;
            action.spawn = [ "wezterm" ];
          };

          "Mod+D" = {
            repeat = false;
            action.spawn = [ "fuzzel" ];
          };

          "Mod+Shift+E".action.quit = [ ];
          "Mod+Shift+Q".action.close-window = [ ];
          "Mod+Shift+P".action.power-off-monitors = [ ];

          "Mod+Shift+Ctrl+Slash" = {
            action.toggle-keyboard-shortcuts-inhibit = [ ];
            allow-inhibiting = false;
          };

          "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

          # window/columns controls
          "Mod+H".action.focus-column-left = [ ];
          "Mod+Left".action.focus-column-left = [ ];
          "Mod+J".action.focus-window-down = [ ];
          "Mod+Down".action.focus-window-down = [ ];
          "Mod+K".action.focus-window-up = [ ];
          "Mod+Up".action.focus-window-up = [ ];
          "Mod+L".action.focus-column-right = [ ];
          "Mod+Right".action.focus-column-right = [ ];
          "Mod+Shift+H".action.move-column-left = [ ];
          "Mod+Shift+Left".action.move-column-left = [ ];
          "Mod+Shift+J".action.move-window-down = [ ];
          "Mod+Shift+Down".action.move-window-down = [ ];
          "Mod+Shift+K".action.move-window-up = [ ];
          "Mod+Shift+Up".action.move-window-up = [ ];
          "Mod+Shift+L".action.move-column-right = [ ];
          "Mod+Shift+Right".action.move-column-right = [ ];
          "Mod+R".action.switch-preset-column-width = [ ];

          "Mod+Space".action.toggle-window-floating = [ ];
          "Mod+Shift+Space".action.switch-focus-between-floating-and-tiling =
            [ ];

          # monitor controls
          "Mod+Ctrl+H".action.focus-monitor-left = [ ];
          "Mod+Ctrl+Left".action.focus-monitor-left = [ ];
          "Mod+Ctrl+J".action.focus-monitor-down = [ ];
          "Mod+Ctrl+Down".action.focus-monitor-down = [ ];
          "Mod+Ctrl+K".action.focus-monitor-up = [ ];
          "Mod+Ctrl+Up".action.focus-monitor-up = [ ];
          "Mod+Ctrl+L".action.focus-monitor-right = [ ];
          "Mod+Ctrl+Right".action.focus-monitor-right = [ ];
          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
          "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
          "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
          "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];
          "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];

          # workspace controls
          "Mod+P".action.focus-workspace-up = [ ];
          "Mod+N".action.focus-workspace-down = [ ];
          "Mod+Ctrl+P".action.move-column-to-workspace-up = [ ];
          "Mod+Ctrl+N".action.move-column-to-workspace-down = [ ];
          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Mod+Shift+6".action.move-column-to-workspace = 6;
          "Mod+Shift+7".action.move-column-to-workspace = 7;
          "Mod+Shift+8".action.move-column-to-workspace = 8;
          "Mod+Shift+9".action.move-column-to-workspace = 9;

          # column editing stuffs
          "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
          "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
          "Mod+F".action.maximize-column = [ ];
          "Mod+Shift+F".action.expand-column-to-available-width = [ ];
          "Mod+Ctrl+F".action.fullscreen-window = [ ];
          "Mod+C".action.center-column = [ ];
          "Mod+Minus".action.set-column-width = "-5%";
          "Mod+Equal".action.set-column-width = "+5%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";
          "Mod+W".action.toggle-column-tabbed-display = [ ];

          # media keys
          "XF86AudioRaiseVolume".action.spawn =
            [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ];
          "XF86AudioLowerVolume".action.spawn =
            [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
          "XF86AudioMute".action.spawn =
            [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
          "XF86AudioMicMute".action.spawn =
            [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
          "XF86AudioRaiseVolume".allow-when-locked = true;
          "XF86AudioLowerVolume".allow-when-locked = true;
          "XF86AudioMute".allow-when-locked = true;
          "XF86AudioMicMute".allow-when-locked = true;

        };
      };
    };
  };
}
