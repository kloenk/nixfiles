{ ... }:

{
  imports =
    [ ./binds.nix ./input.nix ./screenshots.nix ./workspaces.nix ./quirks.nix ];

  programs.niri.enable = true;
  home-manager.users.kloenk = {
    programs.niri = {
      settings = {
        hotkey-overlay.skip-at-startup = true;
        layout = {
          gaps = 15;
          focus-ring.enable = false;
          border = {
            enable = true;
            width = 3;
            inactive.gradient = {
              from = "#f69ecf";
              to = "#ff9a56";
              in' = "oklch shorter hue";
              relative-to = "window";
              angle = 135;
            };
            active.gradient = {
              from = "#f69ecf";
              to = "#5bcefa";
              in' = "oklch shorter hue";
              relative-to = "window";
              angle = 135;
            };
          };
        };
      };
    };
  };

  k.emacs.gui = true;
}
