{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  users.nix.configureBuildUsers = true;
  nix.useDaemon = true;
}
