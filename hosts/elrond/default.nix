{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./links.nix
    ./devenv.nix
    ./podman.nix

    ./syncthing.nix
    ./pipewire.nix
    ./gaming.nix
    ./desktop.nix
    ./hyprland
    ./mpd.nix
    ./disko.nix
    ./evremap.nix
    #./kde.nix

    ../../profiles/desktop
    ../../profiles/desktop/sway
    ../../profiles/desktop/emacs.nix

    ../../profiles/bcachefs.nix

    ../../profiles/telegraf.nix
    # ../../profiles/syncthing.nix
    #../../common/nushell.nix
  ];

  hardware.cpu.amd.updateMicrocode = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.initrd.supportedFilesystems = [ "bcachefs" ];

  boot.initrd.systemd.emergencyAccess = true;

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
    "192.168.178.248" = [ "thrain" "thrain.kloenk.de" "thrain.net.kloenk.de" ];
    "192.168.178.247" = [ "elrond" "elrond.kloenk.de" "elrond.net.kloenk.de" ];
    "192.168.178.246" = [ "gloin" "gloin.kloenk.de" ];
    "192.168.178.1" = [ "fritz.box" ];
  };

  networking.nameservers = [ "thrain" "1.1.1.1" ];
  networking.search = [ "burscheid.home.kloenk.de" ];

  services.printing.browsing = true;
  services.printing.enable = true;
  services.avahi.enable = true;

  environment.systemPackages = with pkgs; [ lm_sensors virt-manager nodejs ];

  users.users.kloenk.password = "foobar";
  #users.users.kloenk.shell = lib.mkOverride 50 config.programs.nushell.wrapper; # FIME: not a shell package

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

  /* boot.kernelPatches = [{
       name = "bcachefs-lock-time";
       patch = null;
       extraConfig = ''
         BCACHEFS_LOCK_TIME_STATS y
       '';
     }];
  */

  # fileSystems."/".device = lib.mkForce "UUID=f19a5f96-9f10-453c-9de2-d351e1e858c8";
  fileSystems."/".device =
    lib.mkForce "/dev/disk/by-partuuid/3ef9d1a6-3036-45e3-bc76-c5f2eebd6492";

  system.stateVersion = "23.05";
}
