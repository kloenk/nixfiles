{ lib, config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./links.nix

    ../../profiles/users/kloenk/password.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  boot.initrd.systemd.enable = true;

  networking.useDHCP = false;
  networking.hostName = "vaire";

  fileSystems."/persist".neededForBoot = true;

  system.stateVersion = "24.11";
}
