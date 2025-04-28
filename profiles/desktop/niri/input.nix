{ ... }:

{
  home-manager.users.kloenk = {
    programs.niri = {
      settings.input = {
        workspace-auto-back-and-forth = true;
        focus-follows-mouse.enable = true;
        keyboard = {
          xkb = {
            layout = "us";
            options = "compose:caps";
          };
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
          dwt = true;
          dwtp = true;
        };
        mouse = { natural-scroll = true; };
      };
    };
  };
}
