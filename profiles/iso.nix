{ modulesPath, lib, pkgs, self, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")

    ./hetzner_vm.nix

    ./base/nixos
  ];

  system.extraDependencies = [
    self.nixosConfigurations.elrond.config.system.build.toplevel
    self.nixosConfigurations.elrond.config.system.build.diskoScript
  ];

  boot.initrd.supportedFilesystems = lib.mkForce [ "vfat" ];
  boot.supportedFilesystems = lib.mkForce [ "cifs" "vfat" "xfs" ];
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_testing;

  networking.wireless.iwd.enable = true;
  networking.wireless.enable = lib.mkForce false;
  networking.useDHCP = true;
  services.getty.autologinUser = lib.mkForce "kloenk";
}

