{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./monitoring

    #./engelsystem.nix
    ./postgres.nix
    ./redis.nix
    ./mysql.nix
    ./gitlab.nix
    #./restya.nix
    ./youtrack.nix
    # ./pleroma # fucking annoying and not working

    ./wireguard.nix
    ./restic-server.nix

    #./fabric.nix
    ./m-sandbox.nix

    ../../default.nix
    ../../common
  ];

  # vm connection
  services.qemuGuest.enable = true;

  boot.supportedFilesystems = [ "xfs" "vfat" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.reusePassphrases = true;
  boot.initrd.luks.devices."cryptData".device =
    "/dev/disk/by-uuid/546b121a-0062-4d3a-b136-716f84630c5b";
  boot.initrd.luks.devices."cryptRoot".device =
    "/dev/disk/by-uuid/622a10b2-8c1c-46c6-a69c-3dbae9721e27";

  boot.initrd.network.enable = true;
  boot.initrd.availableKernelModules = [ "virtio-pci" ];
  boot.initrd.network.ssh = {
    enable = true;
  };

  # delete files in /
  kloenk.transient.enable = true;

  networking.hostName = "manwe";
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;

  networking.interfaces.ens18.useDHCP = true;
  networking.interfaces.ens18.tempAddress = "disabled";

  system.autoUpgrade.enable = true;
  nix.gc.automatic = true;

  systemd.services.nixos-upgrade.path = with pkgs; [
    gnutar
    xz.bin
    gzip
    config.nix.package.out
  ];

  system.stateVersion = "21.03";
}
