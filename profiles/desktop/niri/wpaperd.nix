{ pkgs, ... }:

{
  home-manager.users.kloenk = {
    services.wpaperd = {
      enable = true;
      settings = {
        default = {
          duration = "30m";
          sorting = "random";
        };
        any = { path = "${pkgs.wallpapers}/share/wallpapers/"; };
      };
    };
  };
}
