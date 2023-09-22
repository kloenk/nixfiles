{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./links.nix
    ./devenv.nix
    ./podman.nix

    ./pipewire.nix
    ./gaming.nix
    ./desktop.nix
    ./mpd.nix
    #./kde.nix

    ../../common/telegraf.nix
    ../../common/nushell.nix
  ];

  # FIME: remove
  security.acme.defaults.server =
    builtins.trace "remove staging environment from acme"
    "https://acme-staging-v02.api.letsencrypt.org/directory";

  hardware.cpu.amd.updateMicrocode = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.initrd.supportedFilesystems = [ "bcachefs" ];

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

  environment.systemPackages = with pkgs; [ lm_sensors virt-manager nodejs ];

  users.users.kloenk.password = "foobar";
  #users.users.kloenk.shell = lib.mkOverride 50 config.programs.nushell.wrapper; # FIME: not a shell package

  # virtmanager
  virtualisation.libvirtd = {
    #enable = true;
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

  services.openssh.settings.X11Forwarding = true;

  system.stateVersion = "23.05";
}
