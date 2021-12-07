{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  users.nix.configureBuildUsers = true;
  nix.useDaemon = true;

  environment.systemPackages = with pkgs; [
    jq
    cmake
    bat
    skim
  ];
}
