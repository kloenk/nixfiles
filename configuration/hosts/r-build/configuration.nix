{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../default.nix

    ../../common
    ../../common/transient.nix
  ];

  hardware.cpu.intel.updateMicrocode = true;
  boot.loader.grub.device =
    "/dev/disk/by-id/wwn-0x600508b1001c577e51960d44ae47cb27";

  networking.hostName = "r-build";
  networking.useDHCP = false;

  networking.hosts = {
    "192.168.178.1" = [ "fritz.box" ];
    "192.168.178.248" = [ "thrain" "thrain.fritz.box" ];
    "172.16.0.1" = [ "airlink.local" ];
  };

  boot.initrd.luks.devices."crpytLVM".device = "/dev/disk/by-id/wwn-0x600508b1001c577e51960d44ae47cb27-part2";
  boot.initrd.luks.reusePassphrases = true;


  # delete files in /
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    ${pkgs.xfsprogs}/bin/mkfs.xfs -m reflink=1 -f /dev/${config.networking.hostName}/root
  '';
  fileSystems."/".device = lib.mkForce "/dev/${config.networking.hostName}/root";

  # FIME: remove
  security.acme.server = builtins.trace "remove staging environment from acme"
    "https://acme-staging-v02.api.letsencrypt.org/directory";

  nixpkgs.config.allowUnfree = true;
  nix.gc.automatic = true;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking.interfaces.br0.useDHCP = true;
  networking.interfaces.enp15s0.useDHCP = true;

  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.availableKernelModules = [ "myri10ge" ];

  /*networking.interfaces.br0.ipv4.addresses = [
    {
      address = "192.168.178.249";
      prefixLength = 24;
    }
  ];*/

  systemd.network = {
    networks."20-glas" = {
      name = "enp15s0";
      bridge = [ "br0" ];
    };

    networks."20-copper" = {
      name = "enp?s*";
      bridge = [ "br0" ];
    };

    netdevs."30-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
    };

    networks."30-br0" = {
      name = "br0";
      DHCP = "yes";
      linkConfig.MACAddress = "00:60:dd:45:44:c0";
      networkConfig = { ConfigureWithoutCarrier = true; };
    };
  };

  environment.systemPackages = with pkgs; [ lm_sensors virtmanager ];

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  fileSystems."/var/lib/libvirt" = {
    device = "/persist/data/libvirt";
    fsType = "none";
    options = [ "bind" ];
  };

  users.users.kloenk.extraGroups = [ "libvirtd" ];
  users.users.kloenk.initialPassword = "foobar";

  system.stateVersion = "21.03";
}
