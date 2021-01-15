{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    #./links.nix
    #./mysql.nix
    #./dhcpcd.nix

    ../../default.nix
    ../../common
    ../../common/pbb.nix
    #../../common/syncthing.nix
    #../../desktop
    #../../desktop/sway.nix
    #../../desktop/vscode.nix
  ];


  boot.supportedFilesystems = [ "ext4" ];
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "peregrin";
  networking.useDHCP = false;
  networking.interfaces.enp0s1.useDHCP = true;

  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  users.users.kloenk.initialPassword = "foobaar";
  users.users.kloenk.packages = with pkgs; [
    #python # includes python2 as dependency for vscode
    #platformio # pio command
  ];

  programs.sysdig.enable = false; # no aarch64

  # disable acme
  systemd.services."acme-peregrin.kloenk.dev".enable = false;
  systemd.services."acme-peregrin.kloenk.dev".wantedBy = lib.mkForce [];
  systemd.services."acme-selfsigned-peregrin.kloenk.dev".wantedBy = [ "multi-user.target" ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes sayyou
  # should.
  system.stateVersion = "21.03";
}
