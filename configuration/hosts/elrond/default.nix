{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./links.nix
    ./devenv.nix
    ./desktop.nix

    ../../common/telegraf.nix
  ];

  # FIME: remove
  security.acme.defaults.server =
    builtins.trace "remove staging environment from acme"
    "https://acme-staging-v02.api.letsencrypt.org/directory";

  hardware.cpu.amd.updateMicrocode = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  boot.initrd.luks.devices."cryptRoot".device =
    "/dev/disk/by-uuid/b5de61d7-c49b-4c65-bded-5e08e33803ec";

  networking.useDHCP = false;
  networking.hostName = "elrond";
  networking.domain = "kloenk.dev";
  networking.hosts = {
    "192.168.178.248" = [ "thrain" ];
    "192.168.178.1" = [ "fritz.box" ];
  };

  networking.nameservers = [ "thrain" "fritz.box" "1.1.1.1" ];
  networking.search = [ "fritz.box" ];

  services.printing.browsing = true;
  services.printing.enable = true;
  services.avahi.enable = true;

  environment.systemPackages = with pkgs; [ lm_sensors virtmanager nodejs ];

  users.users.kloenk.password = "foobar";

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

  # smartcard
  services.pcscd.enable = true;
  services.telegraf.extraConfig.inputs = { sensors = { }; };

  services.openssh.forwardX11 = true;

  system.stateVersion = "23.05";
}
