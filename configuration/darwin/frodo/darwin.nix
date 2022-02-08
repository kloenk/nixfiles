{ config, lib, pkgs, ... }:

{
  imports = [
    ../../common/darwin.nix
  ];

  environment.systemPackages = with pkgs; [
    #pkgs.vim
  ];

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
    system-features = benchmark big-parallel recursive-nix
  '';

  users.users.kloenk.packages = with pkgs; [
    elixir
    erlang

    # emacs language servers
    elixir_ls
    irony-server
    sbcl
    sops
  ];

  services.epmd.enable = true;
}
