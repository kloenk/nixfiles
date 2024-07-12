{ lib, pkgs, ... }:

{
  imports = [
    ./links.nix
    ./disko.nix

    ../../profiles/hetzner_vm.nix

    ../../profiles/desktop
    ../../profiles/desktop/sway

    ../../profiles/telegraf.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  networking.useDHCP = false;
  networking.hostName = "strider";
  networking.domain = "kloenk.de";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  fileSystems."/persist".neededForBoot = true;

  system.stateVersion = "24.11";
}
