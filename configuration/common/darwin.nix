{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  users.nix.configureBuildUsers = true;
  nix.trustedUsers = [ "root" "@wheel" "kloenk" ];
  # binary cache
  nix.binaryCachePublicKeys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
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
