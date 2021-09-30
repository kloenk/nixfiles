{ configs, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./wireguard.nix

    ./bitwarden.nix
    ./postgres.nix
    ./website.nix
    #./restic.nix

    ./cgit.nix
    ./gerrit.nix

    ./mysql.nix

    ./coredns.nix

    ../../default.nix
    ../../common
  ];

  # vm connection
  services.qemuGuest.enable = true;

  boot.supportedFilesystems = [ "vfat" "xfs" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.reusePassphrases = true;
  boot.initrd.luks.devices.cryptRoot.device =
    "/dev/disk/by-path/pci-0000:04:00.0-part1";
  boot.initrd.luks.devices.cryptSwap.device =
    "/dev/disk/by-path/virtio-pci-0000:08:00.0";

  # initrd network
  boot.initrd.network.enable = true;
  boot.initrd.availableKernelModules = [ "virtio-pci" ];
  boot.initrd.network.ssh = {
    enable = true;
  };

  # delete files in `/`
  kloenk.transient.enable = true;

  networking.hostName = "iluvatar";
  networking.domain = "kloenk.dev";
  networking.nameservers = [
    "2001:470:20::2"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
    "1.1.1.1"
  ];
  networking.extraHosts = # FIXME: replace with ’networking.hosts‘
    ''
      127.0.0.1 iluvatar.kloenk.dev
    '';

  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.enp1s0.tempAddress = "disabled";

  # running bind/coredn
  services.resolved.enable = false;

  services.vnstat.enable = true;

  # TODO: set DNS via networkd

  # auto update/garbage collector
  system.autoUpgrade.enable = true;
  nix.gc.automatic = true;
  #nix.gc.options = "--delete-older-than 4d";
  #systemd.services.nixos-upgrade.path = with pkgs; [  gnutar xz.bin gzip config.];

  users.users.root.initialPassword = "foobar";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.03";
}
