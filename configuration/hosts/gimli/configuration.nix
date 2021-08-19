{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./mail.nix

    ./wordpress
    ./mysql.nix
    ./moodle.nix
    #./restic.nix

    #./postgres.nix

    #./wireguard.nix
    #./fediventure.nix
    #./jitsi
    #./prosody.nix

    ../../default.nix
    ../../common
    (import ../../common/schluempfli.nix { extraGroups = [ "wheel" ]; })
  ];

  # vm connection
  services.qemuGuest.enable = true;

  boot.supportedFilesystems = [
    #"zfs"
    "vfat"
    "xfs"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.reusePassphrases = true;
  boot.initrd.luks.devices.cryptRoot.device =
    "/dev/disk/by-uuid/9a1b13f9-d9d3-4df4-8a97-7f2d652e0c4e";
  boot.initrd.luks.devices.cryptSwap.device =
    "/dev/disk/by-uuid/3b7e77ec-1627-4a6b-b3fb-242bf1b1ecbc";

  boot.initrd.network.enable = true;
  boot.initrd.availableKernelModules = [ "virtio-pci" ];
  boot.initrd.network.ssh = {
    enable = true;
    #hostKeys = [ "/var/src/secrets/initrd/ed25519_host_key" ];
  };
  /*boot.initrd.network.postCommands = ''
  '';*/

  # setup network
  /*boot.initrd.preLVMCommands = lib.mkBefore (''
    ip li set ens18 up
    ip addr add 195.39.221.51/32 dev ens18
    ip route add default via 195.39.221.1 onlink dev ens18 && hasNetwork=1
  '');*/

  # delete files in /
  kloenk.transient.enable = true;

  fileSystems."/var/src/secrets" = {
    device = "/persist/secrets";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.hostName = "gimli";
  networking.hostId = "8425e349";
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;

  /*systemd.network.networks."40-ens18" = {
    name = "enp1s0";
    DHCP = "yes";
  };*/

  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.enp1s0.tempAddress = "disabled";

  system.autoUpgrade.enable = true;
  nix.gc.automatic = true;

  systemd.services.nixos-upgrade.path = with pkgs; [
    gnutar
    xz.bin
    gzip
    config.nix.package.out
  ];

  system.stateVersion = "21.03";
}
