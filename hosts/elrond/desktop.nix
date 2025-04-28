{ config, pkgs, lib, ... }:

{
  #users.users.kloenk.packages = with pkgs; [ obsidian ];

  systemd.tmpfiles.rules = let
    # Copied from .config/monitors.xml
    monitors-xml = pkgs.writeText "gdm-monitors.xml" ''
      <monitors version="2">
        <configuration>
          <logicalmonitor>
            <x>0</x>
            <y>244</y>
            <scale>1</scale>
            <monitor>
              <monitorspec>
                <connector>DP-1</connector>
                <vendor>LEN</vendor>
                <product>LEN T2224dA</product>
                <serial>V5W53674</serial>
              </monitorspec>
              <mode>
                <width>1920</width>
                <height>1080</height>
                <rate>59.934</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>1920</x>
            <y>0</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>DP-2</connector>
                <vendor>XMI</vendor>
                <product>Mi Monitor</product>
                <serial>0x00000000</serial>
              </monitorspec>
              <mode>
                <width>3440</width>
                <height>1440</height>
                <rate>120.000</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
      </monitors>
    '';
  in [ "L+ /run/gdm/.config/monitors.xml - - - - ${monitors-xml}" ];

  fonts = {
    packages = with pkgs; [
      dejavu_fonts

      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.open-dyslexic
      nerd-fonts.monaspace
      nerd-fonts.dejavu-sans-mono

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      noto-fonts-extra
    ];
    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace =
        [ "FiraCode Nerd Font Mono" "DejaVu Sans Mono" "Noto Sans Mono CJK" ];
      sansSerif = [ "DejaVu Sans" "Noto Sans CJK" ];
      serif = [ "DejaVu Serif" "Noto Serif CJK" ];
    };
  };
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [ wl-clipboard ];

  home-manager.users.kloenk = {
    programs.niri.settings.outputs = {
      "Xiaomi Corporation Mi Monitor Unknown" = {
        #mode = "3440x1440@144.000";
        mode = {
          width = 1440;
          height = 1440;
          refresh = 144.0;
        };
        position = {
          x = 1920;
          y = 10;
        };
        variable-refresh-rate = "on-demand";
      };
      "Lenovo Group Limited LEN T2224dA V5W53674" = {
        mode = {
          width = 1920;
          height = 1080;
        };
        position = {
          x = 0;
          y = 0;
        };
      };
    };
    wayland.windowManager.sway.config.output = {
      "Xiaomi Corporation Mi Monitor Unknown" = {
        mode = "3440x1440@144.000Hz";
        position = "1920 10";
        adaptive_sync = "on";
      };
      "Lenovo Group Limited LEN T2224dA V5W53674" = {
        mode = "1920x1080@59.934Hz";
        position = "0 0";
      };
    };
  };
}
