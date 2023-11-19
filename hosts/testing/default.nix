{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./links.nix

    ../../profiles/bcachefs.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.initrd.supportedFilesystems = [ "bcachefs" ];

  networking.useDHCP = false;
  networking.hostName = "testing";
  networking.domain = "kloenk.dev";
  networking.hosts = {
    "192.168.178.248" = [ "thrain" ];
    "192.168.178.1" = [ "fritz.box" ];
  };

  users.users.kloenk.password = "foobar";
  users.users.root.password = "foobar";

  boot.initrd.network.enable = true;

  system.stateVersion = "23.11";
}
