{ config, pkgs, lib, ... }:

let
  uplink = "ens18";
in {
  imports = [
    ./hardware-configuration.nix

    #./postgres.nix
    #./stream.nix

    #./wireguard.nix

    ../../default.nix
    ../../common
    ../../common/pbb.nix
  ];

  # vm connection
  services.qemuGuest.enable = true;

  boot.supportedFilesystems = [ "vfat" "xfs" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.network.enable = true;
  boot.initrd.availableKernelModules = [ "virtio-pci" ];

  networking.hostName = "usee-nschl";
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;

  networking.interfaces.${uplink}.ipv4.addresses = [{
    address = "5.9.118.93";
  }];
  networking.interfaces.${uplink}.ipv6.addresses = [{
    address = "2a01:4f8:162:6343::3";
  }];
  networking.defaultGateway = {
    address = "5.9.118.73";
    interface = uplink;
  };
  networking.defaultGateway6 = {
    address = "2a01:4f8:162:6343::2";
    interfaces = uplink;
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
