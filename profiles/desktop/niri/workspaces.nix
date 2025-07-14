{ ... }:

{
  home-manager.users.kloenk = {
    programs.niri.settings = {
      workspaces = {
        "01-terminal" = { name = "terminal"; };
        "02-browser" = { name = "browser"; };
        "03-develop" = { name = "develop"; };

        "01-chat" = { name = "chat"; };
      };
      window-rules = [
        {
          matches = [{
            at-startup = true;
            app-id = "^firefox$";
          }];
          open-on-workspace = "firefox";
        }
        {
          matches = [
            {
              at-startup = true;
              app-id = "^emacs$";
            }
            {
              at-startup = true;
              app-id = "^jetbrains-.*$";
            }
          ];
          open-on-workspace = "develop";
        }

        {
          matches = [
            {
              #at-startup = true;
              app-id = "^org.gnome.Fractal$";
            }
            {
              #at-startup = true;
              app-id = "^org.telegram.desktop$";
            }
          ];
          open-on-workspace = "chat";
        }

        # casting
        {
          matches = [{ is-window-cast-target = true; }];
          border = {
            inactive.gradient = {
              from = "#64de50";
              to = "#ff9a56";
              in' = "oklch shorter hue";
              relative-to = "window";
              angle = 135;
            };
            active.gradient = {
              from = "#64de50";
              to = "#5bcefa";
              in' = "oklch shorter hue";
              relative-to = "window";
              angle = 135;
            };
          };
        }
      ];
    };
  };
}
