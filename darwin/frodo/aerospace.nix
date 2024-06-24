{ pkgs, ... }:

let tomlFormat = pkgs.formats.toml { };
in {
  home-manager.users.kloenk.home.file.".aerospace.toml".source =
    tomlFormat.generate "aerospace.toml" {
      mode.main.binding = {
        "cmd-1" = "workspace 1";
        "cmd-2" = "workspace 2";
        "cmd-3" = "workspace 3";
        "cmd-4" = "workspace 4";
        "cmd-5" = "workspace 5";
        "cmd-6" = "workspace 6";
        "cmd-7" = "workspace 7";
        "cmd-8" = "workspace 8";
        "cmd-9" = "workspace 9";
        "cmd-0" = "workspace 0";
        "cmd-shift-1" = "move-node-to-workspace 1";
        "cmd-shift-2" = "move-node-to-workspace 2";
        "cmd-shift-3" = "move-node-to-workspace 3";
        "cmd-shift-4" = "move-node-to-workspace 4";
        "cmd-shift-5" = "move-node-to-workspace 5";
        "cmd-shift-6" = "move-node-to-workspace 6";
        "cmd-shift-7" = "move-node-to-workspace 7";
        "cmd-shift-8" = "move-node-to-workspace 8";
        "cmd-shift-9" = "move-node-to-workspace 9";
        "cmd-shift-0" = "move-node-to-workspace 0";
      };
    };
}
