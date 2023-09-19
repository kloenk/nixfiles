{ pkgs, lib, ... }:

{
  imports = [
    ../../common/nushell.nix
    ./links.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.initrd.supportedFilesystems = [ "bcachefs" ];

  networking.useDHCP = false;
  networking.hostName = "ktest";
  networking.domain = "kloenk.dev";

  users.users.kloenk.password = "foobar";


  nixpkgs.config.allowBroken = true;
  # Hardware config
  boot.initrd.availableKernelModules = [ "xhci_pci" "sr_mod" "bcache" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "bcachefs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  system.stateVersion = "23.05";
}