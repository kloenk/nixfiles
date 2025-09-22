{ pkgs, ... }:

{
  imports = [
    ./binds.nix
    ./input.nix
    ./screenshots.nix
    ./security.nix
    ./systemd.nix
    ./workspaces.nix
    ./quirks.nix
    ./wpaperd.nix
    ./notifications.nix
    ./waybar
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-stable.overrideAttrs (oldAttrs: {
      postInstall = let
        niri-session-systemd = pkgs.writeShellScript "niri-session" ''
          if systemctl --user -q is-active niri.service; then
            echo 'A niri session is already running.'
            exit 1
          fi

          # Start niri and wait for it to terminate.
          systemctl --user --wait start niri.service

          # Force stop of graphical-session.target.
          systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target

          # Unset environment that we've set.
          systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
        '';
      in oldAttrs.postInstall + ''
        cp ${niri-session-systemd} $out/bin/niri-session
      '';
    });
  };
  home-manager.users.kloenk = {
    programs.niri = {
      settings = {
        prefer-no-csd = true;

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

  /* services.displayManager.lemurs = {
       enable = true;
       settings.wayland.scripts_path = "${pkgs.writeScriptBin "niri" ''
         systemctl --user start niri.service
       ''}/bin";
     };
  */

  k.emacs.gui = true;
}
