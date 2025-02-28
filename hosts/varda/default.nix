{ config, pkgs, lib, ... }:

{
  imports = [
    ./disko.nix
    ./links.nix
    ./wireguard.nix
    ./strongswan.nix

    ../../profiles/bcachefs.nix
    ../../profiles/hetzner_vm.nix
    ../../profiles/postgres.nix

    ../../services/atuin
    ../../services/web
    ../../services/bitwarden
    ../../services/owncast
    ../../services/int-acme-ca
    ../../services/keycloak
    ../../services/knot-dns/primary
    ../../services/kresd-dns
    ../../services/monitoring
    ../../services/monitoring/kuma.nix
    ../../services/netbox-old
    ../../services/youtrack

    ../../profiles/telegraf.nix
    ../../profiles/users/kloenk/password.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;

  networking.hostName = "varda";
  networking.domain = "kloenk.de";

  nix.gc.automatic = true;

  services.kresd.instances = 2;
  services.kresd.listenPlain = [
    "[::1]:53"
    "127.0.0.1:53"

    "[2a01:4f8:c013:1a4b:ecba::1]:53"
    "192.168.242.1:53"
  ];

  fileSystems."/persist".neededForBoot = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "youtrack" ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.11";
}
