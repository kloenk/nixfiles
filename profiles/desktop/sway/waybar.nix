{ config, lib, pkgs, ... }:

{
  users.users.kloenk.packages = with pkgs; [ waybar ];
  home-manager.users.kloenk = {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings.mainBar = {
        battery = {
          format = "{icon} {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          states = {
            critical = 10;
            warning = 25;
          };
        };
        clock = {
          format = "{:%a %Y-%m-%d %H:%M:%S%z}";
          interval = 1;
        };
        cpu = { format = " {usage}%"; };
        layer = "top";
        memory = {
          format = " {percentage}%";
          states = {
            critical = 75;
            warning = 15;
          };
        };
        modules-left = [ "sway/workspaces" "sway/mode" "tray" ];
        modules-right = [
          "network"
          "pulseaudio"
          "temperature"
          "cpu"
          "memory"
          "battery"
          "clock"
        ];
        network = {
          format-disconnected = "no network";
          format-ethernet = " connected";
          format-wifi = " {essid} ({signalStrength}%)";
          interval = 5;
          max-length = 50;
          tooltip-format = ''
            IPv4: {ipaddr}/{cidr}
            Frequency: {frequency}MHz
            Strength:{signaldBm}dBm'';
        };
        position = "bottom";
        pulseaudio = {
          format = "{icon} {volume}%";
          format-icons = [ "" "" ];
          format-muted = " muted";
        };
        temperature = {
          critical-threshold = 70;
          format = " {temperatureC}°C";
          hwmon-path = "/sys/class/hwmon/hwmon5/temp1_input";
          interval = 1;
        };
      };
      style = ./waybar-style.css;
    };
  };
}
