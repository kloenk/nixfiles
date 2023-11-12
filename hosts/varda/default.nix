{ config, pkgs, lib, ... }:

{
  imports = [
    ./disko.nix
    ./links.nix

    ../../profiles/bcachefs.nix
    ../../profiles/hetzner_vm.nix
    ../../profiles/postgres.nix

    ../../services/web
    ../../services/bitwarden
    ../../services/monitoring
    ../../services/monitoring/kuma.nix

    ../../profiles/telegraf.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;

  networking.hostName = "gimli";
  networking.domain = "kloenk.de";

  nix.gc.automatic = true;

  fileSystems."/".device =
    lib.mkForce "/dev/disk/by-partuuid/1dbe61d1-5450-46de-9a31-a242aafe7da9";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.11";
}
