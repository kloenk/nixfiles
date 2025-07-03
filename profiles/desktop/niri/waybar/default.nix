{ lib, pkgs, ... }:

let
  style = pkgs.replaceVars ./style.css {
    CHAT_ICON = ./chat.svg;
    TERMINAL_ICON = ./terminal.svg;
    FIREFOX_ICON = ./firefox.svg;
    CODE_ICON = ./code.svg;
  };
in {
  fonts.packages = with pkgs; [ material-icons ];
  home-manager.users.kloenk = {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        # inspired by https://github.com/ashish-kus/waybar-minimal/tree/main
        niri = {
          layer = "top";
          position = "top";

          modules-left = [
            # icon?
            "clock"
            #"weather"
            "memory"
            "cpu"
            "disk"
            "temperature"
            "niri/window"
          ];
          modules-center = [ "niri/workspaces" ];
          modules-right = [
            "privacy"
            # "tray"?
            # "custom/clipboard" ?
            "backlight"
            "idle_inhibitor"
            # "custom/colorpicker"
            "bluetooth"
            # "pulseaudio"
            "wireplumber"
            "network"
            "battery"
            "niri/language"
          ];

          # left
          clock = {
            format = "{:%T}";
            interval = 1;
            tooltip-format = ''

              <big>{:%A, %d %B %Y}</big>
              <tt><small>{calendar}</small></tt>'';
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "left";
              format = {
                months = "<span color='#aeaeae'><b>{}</b></span>";
                weeks = "<span color='#aeaeae'><b>W{:%V}</b></span>";
                weekdays = "<span color='#aeaeae'><b>{}</b></span>";
              };
            };
          };
          # TODO: weather (some sort of Location detection)
          memory = {
            format =
              "<span font-family='Material Icons'>memory_alt</span>{percentage}%";
          };
          cpu = {
            interval = 1;
            format =
              "<span font-family='Material Icons'>memory</span> {usage}%";
            min-length = 6;
            max-length = 6;
            format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
          };
          disk = {
            interval = 30;
            format =
              "<span font-family='Material Icons'>storage</span> {percentage_used}%";
            path = "/";
          };
          temperature = {
            format = " {temperatureC}°C";
            format-critical = " {temperatureC}°C";
            interval = 10;
            critical-threshold = 80;
          };
          "niri/window" = {
            separate-outputs = true;
            format = " - {title}";
            max-length = 32;
            rewrite = { "(.*) — Mozilla Firefox" = "$1"; };
          };

          # center

          "niri/workspaces" = {
            format = "{icon}";
            format-icons = {
              # TODO: named workspaces

              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";

              active = "";
              default = "";
            };

            on-scroll-up = "niri msg action focus-workspace-up";
            on-scroll-down = "niri msg action focus-workspace-down";
          };

          # right
          privacy = {
            modules = [
              {
                type = "screenshare";
              }
              /* {
                   type = "audio-out";
                 }
              */
              { type = "audio-in"; }
            ];
            ignore-monitor = true;
            ignore = [{ # rnnoise filter
              type = "audio-in";
              name = "effect.kloenk.rnnoise.capture";
            }];
          };

          backlight = {
            format = "<span font='12'>{icon}</span>";
            format-icons = [ "" "" "" "" "" "" "" "" "" "" ];

            on-scroll-down = "${lib.getExe pkgs.light} -A 10";
            on-scroll-up = "${lib.getExe pkgs.light} -U 10";
            smooth-scrolling-threshold = 1;
          };

          idle_inhibitor = {
            format = "<span font='12'>{icon}</span>";
            format-icons = {
              activated = "󰈈";
              deactivated = "󰈉";
            };
          };

          bluetooth = {
            format-disabled = "bluetooth_disabled";
            format-off = "bluetooth_disabled";
            format-on = "bluetooth";
            format-connected = "bluetooth_connected";
            format-no-controller = "";

            tooltip-format = ''
              {controller_alias}	{controller_address}

              {num_connections} connected'';
            tooltip-format-connected =
              "{device_alias} {device_battery_percentage}%";
            tooltip-format-enumerate-connected =
              "{device_alias}	{devial_address}";
            tooltip-format-enumerate-connected-battery =
              "{device_alias}	{device_address}	{device_battery_percentage}%";
          };

          wireplumber = {
            format = "{volume}% {icon}";
            format-muted = "<span font='12'></span>";
            format-icons = [ "🕨" "🕩" "🕪" ];
            justify = "center";
            on-click-right = "${lib.getExe pkgs.helvum}";
          };

          network = {
            family = "ipv4_6";
            format-wifi = "network_wifi_3_bar ";
            format-ethernet = "lan";
            format-disconnected = "mobiledata_off";
            tooltip-format = "{ipaddr}";
            tooltip-format-wifi = "{essid} ({signalStrength}%)  | {ipaddr}";
            tooltip-format-ethernet = "{ifname} 🖧 | {ipaddr}";
          };

          battery = {
            interval = 5;
            states = {
              good = 95;
              warning = 30;
              critical = 15;
            };
            format = "{capacity}%  {icon}";
            format-charging = "{capacity}% 󰂄 ";
            format-plugged = "{capacity}% 󰂄 ";
            format-alt = "{time} {icon}";
            format-icons = [ "󰁻" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹" ];
          };

          "niri/language" = {
            format-en = "en";
            format-de = "de";

            on-click = "niri msg action switch-layout next";
            on-scroll-down = "niri msg action switch-layout next";
            on-scroll-up = "niri msg action switch-layout prev";

            on-click-middle = "niri msg action show-hotkey-overlay";
          };

          /* modules-left = [
               "niri/workspaces"
               "niri/window"
             ];
             modules-center = [
             ];
             modules-right = [
               "privacy"
               "cpu"
               #"tray"
               "bluetooth"
               "niri/language"
               "clock"
             ];
          */

          /* "niri/workspaces" = {
               format = "{icon}";
               format-icons = {
                 #terminal = " ";
                 terminal = "  ";
                 browser = "  ";
                 develop = " ";
                 chat = "  ";
               };
               current-only = true;

               on-scroll-up = "niri msg action focus-workspace-up";
               on-scroll-down = "niri msg action focus-workspace-down";
             };
             "niri/window" = {
               separate-outputs = true;
               rewrite = {
                 "(.*) — Mozilla Firefox" = "$1";
               };
               icon = true;
               icon-size = 12;
             };
             "niri/language" = {
               format-en = "en";
               format-de = "de";

               on-click = "niri msg action switch-layout next";
               on-scroll-down = "niri msg action switch-layout next";
               on-scroll-up = "niri msg action switch-layout prev";

               on-click-middle = "niri msg action show-hotkey-overlay";
             };

             privacy = {
               modules = [
                 {
                   type = "screenshare";
                 }
                 /*{
                   type = "audio-out";
                 }
          */
          /* {
                   type = "audio-in";
                 }
               ];
               ignore-monitor = true;
               ignore = [
                 { # rnnoise filter
                   type = "audio-in";
                   name = "effect.kloenk.rnnoise.capture";
                 }
               ];
             };
             bluetooth = {
               format-disabled = "bluetooth_disabled";
               format-off = "bluetooth_disabled";
               format-on = "bluetooth";
               format-connected = "bluetooth_connected";
               format-no-controller = "";

               tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
               tooltip-format-connected = "{device_alias} {device_battery_percentage}%";
               tooltip-format-enumerate-connected = "{device_alias}\t{devial_address}";
               tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
             };
             cpu = {
               interval = 2;
               format = "{icon}";
               format-icons = [
                 "<span color='#69ff94'>▁</span>"
                 "<span color='#2aa9ff'>▂</span>"
                 "<span color='#f8f8f2'>▃</span>"
                 "<span color='#f8f8f2'>▄</span>"
                 "<span color='#ffffa5'>▅</span>"
                 "<span color='#ffffa5'>▆</span>"
                 "<span color='#ff9977'>▇</span>"
                 "<span color='#dd532e'>█</span>"
               ];
               states = {
                 medium = 30;
                 high = 70;
                 warn = 90;
               };
               # tooltip-format = "{load}\n{usage}\n{avg_frequency}\t{min_frequency}/{max_frequency}";
             };
             clock = {

             };
          */
          # TODO: cava (it's fancy)
        };
      };
      style = style;
    };
  };
}
