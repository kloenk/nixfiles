{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ "e1000e" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.systemd.mounts = [{
    what = "UUID=0db29e0c-e655-4cdf-aca4-1256aee2b81e";
    where = "/sysroot";
    type = "bcachefs";
  }];
  fileSystems."/".device = "none";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A76D-CE71";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/a68e28a3-2db2-49a3-9c4c-7d7f6c20f5fa"; }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
