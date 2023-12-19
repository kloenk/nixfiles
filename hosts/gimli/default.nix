{ config, pkgs, lib, ... }:

{
  imports = [
    ./disko.nix
    ./links.nix

    ../../profiles/bcachefs.nix
    ../../profiles/hetzner_vm.nix
    ../../profiles/postgres.nix

    ../../services/matrix
    ../../services/mail
    ../../services/kresd-dns
    ../../services/knot-dns/secondary

    ../../profiles/telegraf.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;

  networking.hostName = "gimli";
  networking.domain = "kloenk.de";

  nix.gc.automatic = true;

  fileSystems."/".device =
    lib.mkForce "/dev/disk/by-partuuid/b9c887ad-75f8-4d6f-8cf6-4ee63c07a203";

  # knot host specific settings
  networking.interfaces.lo.ipv4.addresses = [{
    address = "127.0.0.11";
    prefixLength = 8;
  }];
  systemd.network.networks."30-wg0".addresses =
    [{ addressConfig.Address = "2a01:4f8:c013:1a4b:ecba::21:53/128"; }];
  services.knot.settings.server.listen = [
    "127.0.0.11@53"

    "49.12.72.200@53"
    "2a01:4f8:c012:b874::@53"

    "2a01:4f8:c013:1a4b:ecba::2"
    "2a01:4f8:c013:1a4b:ecba::21:53@53"
  ];

  services.kresd.instances = 4;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.11";
}
