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
  boot.initrd.systemd.emergencyAccess = true;

  boot.initrd.systemd.network = { enable = true; };
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.port = 62955;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.hostKeys = [ "/persist/data/openssh/ed25519_key" ];

  boot.kernelPatches = [{
    name = "bcachefs-lock-time";
    patch = null;
    extraConfig = ''
      BCACHEFS_LOCK_TIME_STATS y
    '';
  }];

  system.stateVersion = "23.11";
}

