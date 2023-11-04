{ config, pkgs, lib, ... }:

{ 
  imports = [
    ./disko.nix
    ./links.nix

    ../../profiles/bcachefs.nix

    # ./mail
    # ./matrix
    # ./dns    

    ./postgres.nix

    ../../common/telegraf.nix
  ];

  # vm connection
  services.qemuGuest.enable = true;

  boot.supportedFilesystems = [ "vfat" "bcachefs" ];
  boot.initrd.supportedFilesystems = [ "bcachefs" ];
  boot.initrd.kernelModules = [ "virtio_gpu" ];
  boot.kernelParams = [
    "console=tty"
  ];
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;

  networking.hostName = "gimli";
  networking.domain = "kloenk.de";

  nix.gc.automatic = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.11";
}