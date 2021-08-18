{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    #./links.nix
    #./mysql.nix
    #./dhcpcd.nix

    ../../default.nix
    ../../common
    ../../common/transient.nix
    #../../common/syncthing.nix
    #../../desktop
    #../../desktop/sway.nix
    #../../desktop/vscode.nix

  ];


  boot.supportedFilesystems = [ "xfs" ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # delete files in /
  kloenk.transient.enable = true;
  /*boot.initrd.postDeviceCommands = lib.mkAfter ''
    ${pkgs.xfsprogs}/bin/mkfs.xfs -m reflink=1 -f /dev/${config.networking.hostName}/root
  '';
  fileSystems."/".device = lib.mkForce "/dev/${config.networking.hostName}/root";*/

  networking.hostName = "peregrin";
  networking.useDHCP = false;
  networking.interfaces.enp5s0.useDHCP = true;

  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  console.keyMap = lib.mkForce "de"; # Parallels is not able to use neo2

  users.users.kloenk.initialPassword = "foobar";
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
  system.stateVersion = "21.11";
}
