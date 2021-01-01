{ config, pkgs, lib, ... }:

{
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

  networking.interfaces.ens18.ipv4.addresses = [{
    address = "5.9.118.93";
    prefixLenght = 32;
  }];
  networking.interfaces.ens18.ipv6.addresses = [{
    address = "2a01:4f8:162:6343::3";
    prefixLength = 128;
  }];

  systemd.network.networks."40-ens18" = {
    name = "ens18";
    networkConfig = { IPv6AcceptRA = "no"; };
    routes = [
      {
        routeConfig.Gateway = "22a01:4f8:162:6343::2";
        routeConfig.GatewayOnLink = "yes";
        routeConfig.PreferredSource = "2a01:4f8:162:6343::3";
      }
      {
        routeConfig.Gateway = "5.9.118.73";
        routeConfig.GatewayOnLink = "yes";
      }
    ];
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
