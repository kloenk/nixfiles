{ ... }:

{
  home-manager.users.kloenk = {
    programs.niri.settings = {
      window-rules = [
        # clion
        {
          matches = [{
            app-id = "^jetbrains-.*$";
            title = "^Welcome to .*$";
          }];
          baba-is-float = false;
          open-focused = false;
          open-floating = true;
        }
      ];

      environment.ELECTRON_OZON_PLATFORM_HINT = "auto";
    };
  };
}
