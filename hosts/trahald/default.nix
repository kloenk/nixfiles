{ ... }:

{
  imports = [
    ./disko.nix
    ./links.nix

    #./strongswan.nix

    ../../profiles/users/kloenk/password.nix
    ../../profiles/mosh.nix

    ../../profiles/telegraf.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  networking.useDHCP = false;
  networking.hostName = "trahald";

  fileSystems."/persist".neededForBoot = true;

  system.stateVersion = "25.11";
}
