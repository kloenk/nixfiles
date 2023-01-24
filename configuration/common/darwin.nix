{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  nix.configureBuildUsers = true;
  nix.useDaemon = true;

  documentation.enable = false;
  programs.man.enable = true;
  programs.info.enable = true;

  environment.systemPackages = with pkgs; [
    jq
    cmake
    bat
    skim

    #colmena

    gnupg
    pinentry_mac
  ];
}
