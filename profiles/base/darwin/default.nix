{ lib, pkgs, ... }:

{
  imports = [
    ../default.nix
    ../../users/kloenk/hm.nix
    ../../users/kloenk/kloenk.nix
    ../../users/root
  ];

  nix.configureBuildUsers = true;
  nix.useDaemon = true;

  documentation.enable = true;

  programs.man.enable = true;
  programs.info.enable = true;

  sops.age.generateKey = true;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  home-manager.useUserPackages = true;
  home-manager.users.kloenk.home.homeDirectory = lib.mkForce "/Users/kloenk";

  environment.systemPackages = with pkgs; [
    jq
    bat
    skim

    gnupg
    pinentry_mac
  ];

  environment.systemPath = [
    "/nix/var/nix/profiles/default"
    "/run/current-system/sw/bin"
    "/run/current-system/etc/profiles/per-user/$USER"
  ];

  programs.git.config.credential.helper = "credential";
  environment.variables.GIT_CONFIG_SYSTEM = "/etc/gitconfig";

  # zsh options that are renamed on darwin
  programs.zsh = { enableSyntaxHighlighting = true; };
}
