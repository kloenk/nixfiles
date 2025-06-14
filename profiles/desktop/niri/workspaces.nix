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
      ];
    };
  };
}
