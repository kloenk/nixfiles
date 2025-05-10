{ lib, config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./links.nix

    ../../profiles/hetzner_vm.nix
    ../../profiles/postgres.nix

    ../../services/netbox
    #../../services/kitchenowl
    ../../services/snipe-it
    ../../services/hedgedoc
    ../../services/vpn-acme-ca
    ../../services/part-db
    ../../services/inventree

    ../../profiles/telegraf.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  boot.initrd.systemd.enable = true;

  networking.useDHCP = false;
  networking.hostName = "vaire";

  fileSystems."/persist".neededForBoot = true;

  system.stateVersion = "24.11";
}

