{ lib, pkgs, ... }:

{
  home-manager.users.kloenk = {
    home.stateVersion = "23.11";
    manual.manpages.enable = false;
  };
}
