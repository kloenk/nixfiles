{ config, lib, pkgs, ... }:

{
  imports = [
    ../../common/darwin.nix
  ];

  environment.systemPackages = [
    #pkgs.vim
  ];

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
    system-features = benchmark big-parallel recursive-nix
  '';
}
