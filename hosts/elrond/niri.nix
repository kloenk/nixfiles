{ ... }:

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
  };
}
