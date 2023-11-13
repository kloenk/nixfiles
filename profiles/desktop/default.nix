{ config, lib, ... }:

{
  imports = [ ./applications.nix ./alacritty.nix ./firefox.nix ];
}
