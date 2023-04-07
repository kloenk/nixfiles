{ config, pkgs, lib, ... }:

{
    programs.firefox = {
        enable = true;
        languagePacks = [ "en-GB" "de" ];
    };

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
    in [
        "L+ /run/gdm/.config/monitors.xml - - - - ${monitors-xml}"
    ];

    fonts = {
        fonts = with pkgs; [
            dejavu_fonts
            (nerdfonts.override {
                fonts = [
                    "CascadiaCode"
                    "DejaVuSansMono" "SourceCodePro"
                    "Ubuntu" "UbuntuMono"
                ];
            })
            noto-fonts
            noto-fonts-cjk
            noto-fonts-emoji
            noto-fonts-extra
        ];
        fontconfig.defaultFonts = {
            emoji = [ "Noto Color Emoji" ];
            monospace = [ "FiraCode Nerd Font Mono" "DejaVu Sans Mono" "Noto Sans Mono CJK" ];
            sansSerif = [ "DejaVu Sans" "Noto Sans CJK" ];
            serif = [ "DejaVu Serif" "Noto Serif CJK" ];
        };
    };
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [ gnomeExtensions.twitchlive-panel ];

}