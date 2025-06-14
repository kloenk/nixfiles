{ pkgs, config, ... }:

let
  main = "DP-2";
  side-left = "DP-1";
in {
  home-manager.users.kloenk = {
    programs.niri.settings = {
      workspaces = {
        "01-terminal".open-on-output = main;
        "02-browser".open-on-output = main;
        "03-develop".open-on-output = main;

        "01-chat".open-on-output = side-left;
      };
    };

    xdg.autostart = {
      enable = true;
      readOnly = true;
      entries = [
        "${pkgs.fractal}/share/applications/org.gnome.Fractal.desktop"
        "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
        "${pkgs.firefox}/share/applications/firefox.desktop"
        "${config.home-manager.users.kloenk.programs.emacs.finalPackage}/share/applications/emacsclient.desktop"
      ];
    };
  };
}
