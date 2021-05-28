{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./links.nix
    ./dhcpd.nix
    ./nfs.nix
    #./timemachine.nix
    ./samba.nix

    ./factorio.nix

    ./dns.nix
    ./unify.nix

    ../../default.nix

    #../../desktop
    #../../desktop/plasma.nix
    #../../desktop/sway.nix
    #../../desktop/gnome.nix

    ./bbb-backup.nix

    ../../common
    ../../common/transient.nix
    ../../common/syncthing.nix
  ];

  # FIME: remove
  security.acme.server = builtins.trace "remove staging environment from acme"
    "https://acme-staging-v02.api.letsencrypt.org/directory";

  hardware.cpu.intel.updateMicrocode = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = [ "zfs" ];

  boot.initrd.luks.devices."cryptLVM".device =
    "/dev/disk/by-id/wwn-0x5002538e40df324b-part1";
  boot.initrd.luks.devices."cryptLVM".allowDiscards = true;
  boot.initrd.luks.devices."cryptIntenso".device =
    "/dev/disk/by-id/usb-Intenso_External_USB_3.0_20150609040398-0:0-part5";
  boot.initrd.luks.reusePassphrases = true;

  users.users.kloenk.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuyJjJNWSxO8CFBueBstfdWN4EQBkKfz+A5RsAnR2F9 kloenk@barahir"
  ];

  networking.useDHCP = false;
  networking.hostName = "thrain";
  networking.domain = "kloenk.dev";
  networking.hosts = {
    "192.168.178.1" = lib.singleton "fritz.box";
    "172.16.0.1" = lib.singleton "airlink.local";
    # TODO: barahir
    # TODO: kloenkX?
  };

  # initrd ssh server
  boot.initrd.network.enable = true;
  boot.initrd.availableKernelModules = [ "e1000e" ];
  boot.initrd.network.ssh = {
    enable = true;
  };
  boot.initrd.preLVMCommands = lib.mkBefore (''
    ip li set eno1 up
    ip addr add 192.168.178.248/24 dev eno1 && hasNetwork=1
  '');

  # TODO: use bind
  networking.nameservers = [ "1.1.1.1" "192.168.178.1" "2001:4860:4860::8888" ];
  networking.search = [ "fritz.box" ];
  networking.hostId = "37507120";

  # delete files in /
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    ${pkgs.xfsprogs}/bin/mkfs.xfs -m reflink=1 -f /dev/thrain/root
  '';
  fileSystems."/".device = lib.mkForce "/dev/thrain/root";

  services.printing.browsing = true;
  services.printing.enable = true;
  services.avahi.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "chromium"
    "factorio-headless"
    "chromium-unwrapped"
    "chrome-widevine-cdm"
  ];

  environment.systemPackages = with pkgs; [ lm_sensors virtmanager nodejs ];

  # docker
  #virtualisation.docker.enable = true;
  hardware.steam-hardware.enable = false;

  # virtmanager
  virtualisation.libvirtd = {
    #enable = true;
    onShutdown = "shutdown";
  };

  users.users.kloenk.extraGroups = [
    "docker" # enable docker controll
    "libvirtd" # libvirtd connections
    "audio"
  ];
  users.users.kloenk.home = "/persist/data/kloenk";

  # pa stream foo
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    #systemWide = true;
    package = pkgs.pulseaudio;
    tcp.enable = true;
    tcp.anonymousClients.allowedIpRanges = [
      "195.39.246.0/24"
      "2a0f:4ac0::/64"
      "2a0f:4ac0:40::/44"
      "2a0f:4ac0:f199::/48"
      "192.168.178.0/24"
      "2a0a:a541:9ac9:0::/64"
    ];
  };
  networking.firewall.interfaces.eno1.allowedTCPPorts = lib.singleton 4713;

  system.autoUpgrade.enable = true;

  #services.calibre-server.enable = true;
  #services.calibre-server.libraryDir = "/persist/data/syncthing/data/Library";
  #users.users.calibre-server.extraGroups = [ "syncthing" ];

  # syncthing
  networking.firewall.allowedTCPPorts = [ 8384 ];
  services.syncthing.dataDir = "/persist/data/syncthing/data";
  services.syncthing.configDir = "/persist/data/syncthing/config";
  services.syncthing.guiAddress = "6.0.2.2:8384";

  # fritz.box
  services.nginx.virtualHosts."thrain.fritz.box" = {
    locations."/public/".alias = "/persist/data/public/";
    locations."/public/".extraConfig = "autoindex on;";
  };

  # smartcard
  services.pcscd.enable = true;

  system.stateVersion = "20.09";
}
