{ config, lib, pkgs, ... }:

{
  hardware.graphics.enable = true;

  programs.sway.enable = true;
  programs.light.enable = true;

  users.users.kloenk.packages = with pkgs; [ wdisplays waypipe ];

  /* environment.variables.SDL_VIDEODRIVER = "wayland";
     environment.variables.QT_QPA_PLATFORM = "wayland";
     environment.variables.QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
     environment.variables._JAVA_AWT_WM_NONREPARENTING = "1";
     environment.variables.NIXOS_OZONE_WL = "1";
  */

  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals =
    [ pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.preferred.default = "gtk;wlr";

  home-manager.users.kloenk = {
    programs.wofi.enable = true;
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        screenshots = true;
        clock = true;
        effect-blur = "20x10";
      };
    };
    services.swayidle = let
      lockCommand =
        "${pkgs.systemd}/bin/systemctl --user start swaylock.service";
      #"${pkgs.swaylock-effects}/bin/swaylock -f --screenshots --clock --effect-blur 20x10";
    in {
      enable = true;
      events = [
        {
          event = "lock";
          command = lockCommand;
        }
        {
          event = "unlock";
          command =
            "${pkgs.systemd}/bin/systemctl --user stop swaylock.service";
        }
        {
          event = "before-sleep";
          command = lockCommand;
        }
      ];
      timeouts = [
        {
          timeout = 300;
          command = lockCommand;
        }
        {
          timeout = 600;
          command = ''${pkgs.sway}/bin/swaymsg "output * power off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * power on"'';
        }
      ];
    };
    wayland.windowManager.sway = let
      cfg = config.home-manager.users.kloenk.wayland.windowManager.sway;
      # wallpaper = "~/.wallpapers/bg.jpg";
      wallpaper = "`find ${pkgs.wallpapers}/share/wallpapers/* | shuf -n 1`";
      modifier = "Mod4";
    in {
      enable = true;
      package = pkgs.sway;
      wrapperFeatures.gtk = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
      };

      config = {
        workspaceAutoBackAndForth = true;
        startup = [{
          command = "${pkgs.systemd}/bin/loginctl lock-session";
          always = false;
        }];
        fonts = {
          names = [ "JetBrains Mono" ];
          size = 8.0;
        };
        terminal = "${pkgs.wezterm}/bin/wezterm"; # "alacritty";
        menu = "${pkgs.wofi}/bin/wofi --show drun";

        bars = [ ];

        window = {
          border = 0;
          hideEdgeBorders = "both";
        };
        gaps.inner = 10;

        output = { "*" = { bg = "${wallpaper} fill"; }; };

        input = {
          "*" = { xkb_options = "compose:caps"; };
          "type:touchpad" = {
            tap = "enabled";
            dwt = "disabled";
            natural_scroll = "enabled";
          };
        };

        keybindings = {
          "${modifier}+Return" = "exec ${cfg.config.terminal}";

          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          "${modifier}+h" = "split h";
          "${modifier}+v" = "split v";

          "${modifier}+s" = "layout stacked";
          "${modifier}+w" = "layout tabbed";

          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";
          "${modifier}+a" = "focus parent";

          "${modifier}+f" = "fullscreen toggle";

          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+7" = "workspace 7";
          "${modifier}+8" = "workspace 8";
          "${modifier}+9" = "workspace 9";
          "${modifier}+0" = "workspace 10";
          "${modifier}+F1" = "workspace 11";
          "${modifier}+F2" = "workspace 12";
          "${modifier}+F3" = "workspace 13";
          "${modifier}+F4" = "workspace 14";
          "${modifier}+F5" = "workspace 15";
          "${modifier}+F6" = "workspace 16";
          "${modifier}+F7" = "workspace 17";
          "${modifier}+F8" = "workspace 18";
          "${modifier}+F9" = "workspace 19";
          "${modifier}+F10" = "workspace 20";

          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9";
          "${modifier}+Shift+0" = "move container to workspace 10";
          "${modifier}+Shift+F1" = "move container to workspace 11";
          "${modifier}+Shift+F2" = "move container to workspace 12";
          "${modifier}+Shift+F3" = "move container to workspace 13";
          "${modifier}+Shift+F4" = "move container to workspace 14";
          "${modifier}+Shift+F5" = "move container to workspace 15";
          "${modifier}+Shift+F6" = "move container to workspace 16";
          "${modifier}+Shift+F7" = "move container to workspace 17";
          "${modifier}+Shift+F8" = "move container to workspace 18";
          "${modifier}+Shift+F9" = "move container to workspace 19";
          "${modifier}+Shift+F10" = "move container to workspace 20";

          "XF86AudioRaiseVolume" =
            "exec --no-startup-id ${pkgs.pamixer}/bin/pamixer -i 5";
          "XF86AudioLowerVolume" =
            "exec --no-startup-id ${pkgs.pamixer}/bin/pamixer -d 5";
          "XF86AudioMute" =
            "exec --no-startup-id ${pkgs.pamixer}/bin/pamixer -t";
          "XF86AudioMicMute" =
            "exec --no-startup-id ${pkgs.pamixer}/bin/pamixer --default-source -t";
          "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 5";
          "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 5";

          "${modifier}+l" = "exec loginctl lock-session";
          "${modifier}+d" = "exec ${cfg.config.menu}";

          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+e" = "exit";
          "${modifier}+Shift+q" = "kill";

          "${modifier}+r" = "mode resize";

          "${modifier}+Shift+s" = ''
            exec ${pkgs.grim}/bin/grim -t png -l 1 -g "$(${pkgs.slurp}/bin/slurp)" ~/screenshot-$(date +%Y-%m-%d_%H-%m-%s).png'';
        };

      };
      extraConfig = ''
        client.focused #00000000 #000000cc #FFFFFF
        client.unfocused #00000000 #00000070 #FFFFFF
        client.focused_inactive #00000000 #00000090 #FFFFFF
        titlebar_border_thickness 3
        titlebar_padding 8 6
      '';

    };
  };
}
