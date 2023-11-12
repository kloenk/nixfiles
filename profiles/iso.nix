{ modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")

    ./bcachefs.nix
    ./hetzner_vm.nix

    ./base/nixos
  ];

  boot.initrd.supportedFilesystems = lib.mkForce [ "vfat" "bcachefs" ];
  boot.supportedFilesystems = lib.mkForce [ "bcachefs" "cifs" "vfat" "xfs" ];

  networking.wireless.iwd.enable = true;
  networking.wireless.enable = lib.mkForce false;
  networking.useDHCP = true;
  services.getty.autologinUser = lib.mkForce "kloenk";
}
