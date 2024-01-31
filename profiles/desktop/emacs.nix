{ pkgs, ... }:

{
  users.users.kloenk.packages = [ pkgs.rust-analyzer ];

  home-manager.users.kloenk = {
    home.file = {
      ".emacs.d/init.el".source =
        "${pkgs.kloenk-emacs.passthru.compiledConfig}/init.elc";
      ".emacs.d/early-init.el".source =
        "${pkgs.kloenk-emacs.passthru.compiledConfig}/early-init.elc";
    };

    programs.emacs = {
      enable = true;
      package = pkgs.kloenk-emacs;
    };

    # Broken with emacs-pgkt
    /* services.emacs = {
         enable = true;
         client.enable = true;
         package = pkgs.kloenk-emacs;
         defaultEditor = true;
         socketActivation.enable = true;
       };
    */
  };
}
