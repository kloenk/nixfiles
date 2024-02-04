{ pkgs, lib, ... }:

{
  imports = [
    ./links.nix

    ../../profiles/bcachefs.nix
    ../../profiles/hetzner_vm.nix

    ../../services/kresd-dns
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "bcachefs" "virtiofs" ];
  boot.initrd.supportedFilesystems = [ "bcachefs" ];

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  networking.useDHCP = false;
  networking.hostName = "ktest";
  networking.domain = "kloenk.de";

  users.users.kloenk.password = "foobar";

  nixpkgs.config.allowBroken = true;
  # Hardware config
  boot.initrd.availableKernelModules = [ "xhci_pci" "sr_mod" "bcache" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-partuuid/2af244c2-ed06-4129-a137-c15a7fb8fac8";
    fsType = "bcachefs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/home/kloenk/Developer" = {
    device = "share";
    fsType = "9p";
    options = [ "trans=virtio" "version=9p2000.L" ];
  };

  swapDevices = [ ];

  networking.firewall.allowedUDPPorts = [ 53 ];
  services.kresd.listenPlain = [ "53" ];
  services.kresd.instances = 6;

  environment.systemPackages = with pkgs; [ nodejs ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  system.stateVersion = "23.05";
}
