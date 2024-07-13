{ pkgs, ... }:

{
  /* users.users.kloenk.packages = [ pkgs.rust-analyzer ];

     home-manager.users.kloenk = {
       programs.emacs = {
         enable = true;
         package = if pkgs.stdenv.isLinux then
           pkgs.emacs-config
         else
           pkgs.emacs-config.override { emacs = pkgs.emacs-macport; };
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
  # };
}
