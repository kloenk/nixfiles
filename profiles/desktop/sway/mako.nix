{ config, pkgs, ... }:

let
  swayConfig =
    config.home-manager.users.kloenk.wayland.windowManager.sway.config;
in {
  users.users.kloenk.packages = with pkgs; [ mako ];
  home-manager.users.kloenk = {
    services.mako = {
      enable = true;
      defaultTimeout = 10000;
      borderColor = "#ffffff";
      backgroundColor = "#00000070";
      textColor = "#ffffff";
    };
    wayland.windowManager.sway.config.startup = [{
      command = "${pkgs.mako}/bin/mako";
      always = false;
    }];
  };
}
