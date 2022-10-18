{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  nix.configureBuildUsers = true;
  nix.useDaemon = true;

  environment.systemPackages = with pkgs; [
    jq
    cmake
    bat
    skim

    gnupg
    pinentry_mac
  ];
}
