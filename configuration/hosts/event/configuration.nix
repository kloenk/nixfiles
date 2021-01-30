{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    #./wireguard.nix
    #./fediventure.nix
    ./jitsi
    ./prosody.nix

    ../../default.nix
    ../../common
    ../../common/pbb.nix
    (import ../../common/schluempfli.nix { extraGroups = [ "wheel" ]; })
  ];

  boot.supportedFilesystems = [ "ext2" "vfat" "xfs" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.mirroredBoots = [
    {
      devices = [
        "/dev/disk/by-id/wwn-0x50014eef0100aef5"
      ];
      path = "/boot/a";
    }
    {
      devices = [
        "/dev/disk/by-id/wwn-0x5000cca24bd020aa"
      ];
      path = "/boot/b";
    }
  ];

  boot.initrd.network.enable = true;

  # delete files in /
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    ${pkgs.xfsprogs}/bin/mkfs.xfs -m reflink=1 -f /dev/event/root
  '';
  fileSystems."/".device = lib.mkForce "/dev/event/root";

  networking.hostName = "event";
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;

  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.enp4s0.tempAddress = "disabled";

  systemd.network.networks."10-dhcp" = {
    name = "e*";
    DHCP = "yes";
  };

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
