{ config, pkgs, ... }:

{
  imports = [
    ./nix.nix
  ];

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    eza
    fd
    ripgrep
    htop
  ];

  sops.defaultSopsFile = ../../secrets + "/${config.networking.hostName}.yaml";

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}