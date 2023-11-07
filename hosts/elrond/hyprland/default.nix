{ pkgs, ... }:

let config = ./hyperland.conf;
in {
  programs.hyprland = { enable = true; };

  environment.systemPackages = with pkgs; [ wezterm ];

  systemd.user.tmpfiles.rules =
    [ "L+ %h/.config/hypr/hyprland.conf  - - - - ${config}" ];
}
