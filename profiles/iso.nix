{ modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")

    ./bcachefs.nix
    ./base/nixos
  ];

  boot.initrd.supportedFilesystems = lib.mkForce [ "vfat" "bcachefs" ];
  boot.supportedFilesystems = lib.mkForce [ "bcachefs" "cifs" "vfat" "xfs" ];
}
