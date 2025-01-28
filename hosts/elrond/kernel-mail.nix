{ lib, config, pkgs, ... }:

{
  home-manager.users.kloenk = {
    accounts.email.accounts."me@kloenk.dev" = {
      passwordCommand =
        "${pkgs.libsecret}/bin/secret-tool lookup email me@kloenk.dev host gimli.kloenk.de | base64 -d";
    };

    programs.msmtp = { enable = true; };

    programs.mbsync = { enable = true; };
    services.mbsync = {
      enable = true;
      postExec = "${pkgs.mu}/bin/mu index";
    };

    programs.mu = { enable = true; };
  };

  k.emacs = {
    #extraPackages = epkgs: with epkgs; [ mu4e ];
    extraPackageLiterals = [ "mu4e" ];
    # TODO: proper config not hardcoded
    /* extraPackages = epkgs:
         [(epkgs.trivialBuild {
           pname = "foo";
           src = pkgs.writeText "default.el" "(message \"foo\")";
           version = "0.1.0";
           #packageRequires = packages;
         })];
       extraConfig = let
         mailAccounts = lib.attrNames config.home-manager.users.kloenk.accounts.email.accounts;
         mailAccountsList = lib.concatStringsSep " " (map (v: "\"${v}\"") mailAccounts);
       in ''
         (message "Loading elrond specific emacs config...")
         (defvar kloenk/mu4e-user-mail-address-list '(${mailAccountsList}))
       '';
    */
  };
}
