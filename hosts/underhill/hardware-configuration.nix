{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fcf9b304-a839-4733-8690-e468da9afed0";
    fsType = "xfs";
  };

  boot.initrd.luks.devices."cryptroot".device =
    "/dev/disk/by-uuid/068543e5-54ba-42eb-b219-ae94c37ff6fe";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EA56-19FF";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
