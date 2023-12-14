{ pkgs, ... }:

{
  home-manager.users.kloenk.home.file.emacs = {
    source = pkgs.kloenk-emacs.passthru.config;
    target = ".emacs";
  };
  users.users.kloenk.packages = [ pkgs.kloenk-emacs ];
}
