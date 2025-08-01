{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./links.nix
    ./devenv.nix
    ./podman.nix
    ./strongswan.nix

    ./pipewire.nix
    ./gaming.nix
    ./desktop.nix
    # ./hyprland
    # ./mpd.nix
    ./disko.nix
    ./evremap.nix
    ./secureboot.nix
    ./niri.nix
    # ./kde.nix

    ../../profiles/syncthing.nix
    ../../profiles/mosh.nix

    ../../profiles/desktop
    #../../profiles/desktop/sway
    ../../profiles/desktop/niri
    #    ../../profiles/desktop/ios.nix
    ../../profiles/desktop/plymouth.nix
    ../../profiles/desktop/autologin.nix
    ../../profiles/desktop/pam_u2f.nix
    ../../profiles/desktop/mail.nix

    ../../profiles/telegraf.nix
    #../../common/nushell.nix
  ];

  hardware.cpu.amd.updateMicrocode = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" "xfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  boot.kernelParams = [ "amd_iommu=on" ];

  boot.initrd.systemd.emergencyAccess = true;
  # systemd.sysusers.enable = true;

  boot.initrd.systemd.network.enable = true;
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.port = 62955;
  boot.initrd.network.ssh.hostKeys =
    [ "/persist/data/openssh/initrd_ed25519_key" ];

  networking.useDHCP = false;
  networking.hostName = "elrond";
  networking.domain = "kloenk.dev";
  networking.hosts = {
    #"192.168.178.248" = [ "thrain" "thrain.kloenk.de" "thrain.net.kloenk.de" ];
    #"192.168.178.247" = [ "elrond" "elrond.kloenk.de" "elrond.net.kloenk.de" ];
    #"192.168.178.245" = [ "gloin" "gloin.kloenk.de" ];
    #"192.168.178.1" = [ "fritz.box" ];
    "10.84.16.1" = [ "elros" "elros.kloenk.de" ];
    "fe80::1%br0" = [ "elros" "elros.kloenk.de" ];
    "10.84.19.2" = [ "gloin" "gloin.kloenk.de" ];
  };

  networking.nameservers = [ "thrain" "1.1.1.1" ];
  networking.search = [ "burscheid.home.kloenk.de" ];

  services.printing.browsing = true;
  services.printing.enable = true;
  services.avahi.enable = true;

  environment.systemPackages = with pkgs; [ lm_sensors virt-manager nodejs ];

  # virtmanager
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  users.users.kloenk.extraGroups = [
    "docker" # enable docker controll
    "libvirtd" # libvirtd connections
    "audio"
    "pipewire"
  ];

  # smartcard
  services.pcscd.enable = true;
  services.telegraf.extraConfig.inputs = { sensors = { }; };
  systemd.services.telegraf.path = with pkgs; [ lm_sensors ];

  services.openssh.settings.X11Forwarding = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];

  fileSystems."/persist".neededForBoot = true;

  system.stateVersion = "24.11";
}
