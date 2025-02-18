{ lib, config, pkgs, ... }:

{
  home-manager.users.kloenk = {
    accounts.email.accounts."kloenk" = {
      passwordCommand = if pkgs.stdenv.isLinux then
        "${pkgs.libsecret}/bin/secret-tool lookup email me@kloenk.dev host gimli.kloenk.de | base64 -d"
      else
        "security find-generic-password -a mail-finn@kloenk.dev -s gimli.kloenk.de -D mail -w";
    };

    programs.msmtp = { enable = true; };

    programs.mbsync = { enable = true; };
    services.mbsync = {
      enable = pkgs.stdenv.isLinux;
      postExec = "${pkgs.mu}/bin/mu index";
    };

    programs.mu = { enable = true; };
  };

  k.mail = {
    enable = true;
    mu4e = {
      mailinglists.vger = {
        "RfL" = { id = "rust-for-linux"; };
        "LKML" = { id = "lkml"; };
      };

      context."kloenk" = {

      };
      shortcuts = {
        "/kloenk/Inbox" = "I";
        "/kloenk/Sent" = "S";
        "/kloenk/Drafts" = "d";
        "/kloenk/rust-for-linux" = "r";
      };
    };
  };
}
