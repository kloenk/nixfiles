{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    #./postgres.nix

    #./wireguard.nix

    ../../default.nix
    ../../common
    ../../common/pbb.nix
  ];

  # vm connection
  services.qemuGuest.enable = true;

  boot.supportedFilesystems = [ "zfs" "vfat" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;


  boot.initrd.network.enable = true;
  boot.initrd.availableKernelModules = [ "virtio-pci" ];
  boot.initrd.network.ssh = {
    enable = true;
    hostKeys = [ "/var/src/secrets/initrd/ed25519_host_key" ];
  };

  # setup network
  boot.initrd.preLVMCommands = lib.mkBefore (''
    ip li set ens18 up
    ip addr add 195.39.221.51/32 dev ens18
    ip route add default via 195.39.221.1 onlink dev ens18 && hasNetwork=1
  '');

  # delete files in /
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r spool/local/root@blank
  '';

  networking.hostName = "gimli";
  networking.hostId = "8425e349";
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.interfaces.ens18.ipv4.addresses = [{
    address = "195.39.221.51";
    prefixLength = 32;
  }];
  networking.interfaces.ens18.ipv6.addresses = [{
    address = "2a0f:4ac4:42:f144:fa::51";
    prefixLength = 64;
  }];

  systemd.network.networks."40-ens18".routes = [
    {
      routeConfig.Gateway = "195.39.221.1";
      routeConfig.GatewayOnLink = true;
    }
    {
      routeConfig.Gateway = "fe80::5881:4bff:fe7b:615b";
      #routeConfig.GatewayOnLink = true;
    }
  ];

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
