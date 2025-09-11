{ pkgs, config, ... }:

let
  ext = "DP-3";
  builtin = "eDP-1";
in {
  home-manager.users.kloenk = {
    programs.niri.settings = {
      workspaces = {
        "01-terminal".open-on-output = ext;
        "02-browser".open-on-output = ext;
        "03-develop".open-on-output = ext;

        "01-chat".open-on-output = builtin;
      };
    };

    xdg.autostart = {
      enable = true;
      readOnly = true;
      entries = [
        "${pkgs.fractal}/share/applications/org.gnome.Fractal.desktop"
        # "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
        "${pkgs.firefox}/share/applications/firefox.desktop"
        "${config.home-manager.users.kloenk.programs.emacs.finalPackage}/share/applications/emacsclient.desktop"
      ];
    };
  };
}
