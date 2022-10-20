{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./monitoring

    ./postgres.nix
    ./redis.nix
    ./mysql.nix
    ./gitlab-runner.nix
    #./gitlab.nix
    #./restya.nix
    #./youtrack.nix

    ./minecraft.nix

    ./wireguard.nix
    ./restic-server.nix

    #./fabric.nix
    ./m-sandbox.nix
    ./engelsystem.nix

    ../../common/telegraf.nix
    ../../default.nix
  ];

  # vm connection
  services.qemuGuest.enable = true;

  boot.supportedFilesystems = [ "xfs" "vfat" "zfs" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.enableUnstable = lib.mkForce true;
  #boot.zfs.devNodes = "/dev/";
  networking.hostId = "8b8282a6";

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

  services.telegraf.extraConfig.inputs.zfs = {};

  system.stateVersion = "21.03";
}
