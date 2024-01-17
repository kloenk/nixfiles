{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ "e1000e" "wireguard" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.systemd.mounts = [{
    unitConfig.BindsTo = lib.mkForce [ "dev-sda1.device" "dev-sdb.device" ];
    unitConfig.After = lib.mkForce [ "dev-sda1.device" "dev-sdb.device" ];
    what = "/dev/sda1:/dev/sdb";
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
