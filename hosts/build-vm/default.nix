{ pkgs, lib, ... }:

{
  imports = [
    ./links.nix
    ./hardware-config.nix

    ../../profiles/hetzner_vm.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "xfs" "virtiofs" ];
  boot.initrd.supportedFilesystems = [ "xfs" ];

  networking.useDHCP = false;
  networking.hostName = "build-vm";
  networking.domain = "kloenk.de";

  users.users.kloenk.password = "foobar";

  nixpkgs.config.allowBroken = true;
  # Hardware config
  boot.initrd.availableKernelModules = [ "xhci_pci" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  system.stateVersion = "23.11";
}
