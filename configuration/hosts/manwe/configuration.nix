{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./monitoring

    ./engelsystem.nix
    ./postgres.nix
    ./redis.nix
    ./mysql.nix
    ./pleroma

    ./wireguard.nix
    ./restic-server.nix

    ../../default.nix
    ../../common
    ../../common/pbb.nix
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
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    ${pkgs.xfsprogs}/bin/mkfs.xfs -m reflink=1 -f /dev/manwe/root
  '';
  fileSystems."/".device = lib.mkForce "/dev/manwe/root";

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
