{ pkgs, ... }:

{
  home-manager.users.kloenk.home.file.emacs = {
    source = "${pkgs.kloenk-emacs.passthru.compiledConfig}/Emacs.elc";
    target = ".emacs";
  };
  users.users.kloenk.packages = [ pkgs.kloenk-emacs ];
}
