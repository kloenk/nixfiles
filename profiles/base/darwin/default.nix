{ pkgs, ... }:

{
  imports = [
    ../default.nix
  ];

  nix.configureBuildUsers = true;
  nix.useDaemon = true;

  documentation.enable = true;

  programs.man.enable = true;
  programs.info.enable = true;

  sops.age.generateKey = true;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  environment.systemPackages = with pkgs; [
    jq
    bat
    skim

    gnupg
    pinentry_mac
  ];
}