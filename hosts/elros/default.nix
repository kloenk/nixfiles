{ lib, config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./links.nix

    ./network

    ./secureboot.nix

    ../../profiles/users/kloenk/password.nix
    ../../profiles/postgres.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  networking.useDHCP = false;
  networking.hostName = "elros";

  # u-boot
  system.build.uboot = pkgs.ubootElros;
  system.extraDependencies = [ config.system.build.uboot ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "arm-trusted-firmware-rk3588" "rkbin" ];

  fileSystems."/persist".neededForBoot = true;

  system.stateVersion = "24.05";
}
