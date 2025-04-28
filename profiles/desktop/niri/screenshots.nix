{ ... }:

{
  home-manager.users.kloenk = {
    programs.niri = {
      settings = {
        screenshot-path = "~/Pictures/screenshots/%Y-%m-%dT%H:%M:%S.png";
        binds = {
          "Print".action.screenshot = [ ];
          "Ctrl+Print".action.screenshot-screen = [ ];
          "Shift+Print".action.screenshot-window = [ ];

          "Mod+S".action.screenshot = [ ];
          "Mod+Ctrl+S".action.screenshot-screen = [ ];
          "Mod+Shift+S".action.screenshot-window = [ ];
        };
      };
    };
  };
}
