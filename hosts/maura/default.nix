{ ... }:

{
  imports = [
    ./disko.nix
    ./links.nix

    ../../profiles/telegraf.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  boot.initrd.systemd.enable = true;

  networking.useDHCP = false;
  networking.hostName = "maura";

  fileSystems."/persist".neededForBoot = true;

  system.stateVersion = "25.05";
}
