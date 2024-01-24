{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./links.nix

    ../../profiles/bcachefs.nix
    ../../profiles/postgres.nix
    ../../profiles/desktop/syncthing.nix
    ../../profiles/users/kloenk/password.nix

    ./services/syncthing.nix
    ./services/samba.nix
    ./services/proxies.nix

    ../../services/kresd-dns

    ../../profiles/telegraf.nix
  ];

  security.acme.defaults.server =
    "https://acme.net.kloenk.de:8443/acme/acme/directory";

  hardware.cpu.intel.updateMicrocode = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.initrd.supportedFilesystems = [ "bcachefs" ];

  users.users.kloenk.password = "foobar";

  networking.useDHCP = false;
  networking.hostName = "thrain";
  networking.search = [ "fritz.box" ];
  networking.hosts = {
    "192.168.178.1" = lib.singleton "fritz.box";
    "192.168.178.247" = lib.singleton "elrond";
  };

  # allow emergency shell access without password
  boot.initrd.systemd.emergencyAccess = true;

  # initrd network
  boot.initrd.systemd.network.enable = true;
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.port = 62955;
  boot.initrd.network.ssh.hostKeys =
    [ "/persist/data/openssh/initrd_25519_key" ];

  # virtmanager
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
  services.kresd.listenPlain = [ "[::]:53" "0.0.0.0:53" ];
  services.kresd.instances = 4;

  users.users.kloenk.extraGroups = [
    "docker" # enable docker controll
    "libvirtd" # libvirtd connections
    "audio"
  ];

  # keep in sync with elrond to share kernel
  boot.kernelPatches = [{
    name = "bcachefs-lock-time";
    patch = null;
    extraConfig = ''
      BCACHEFS_LOCK_TIME_STATS y
    '';
  }];

  services.telegraf.extraConfig.inputs = { sensors = { }; };
  systemd.services.telegraf.path = with pkgs; [ lm_sensors ];

  system.stateVersion = "24.05";
}
