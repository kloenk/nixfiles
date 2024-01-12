{ config, pkgs, lib, ... }:

{
  imports = [
    ./disko.nix
    ./links.nix
    ./syncthing.nix
    ./pipewire.nix

    ../../profiles/desktop
    ../../profiles/desktop/sway
    ../../profiles/desktop/emacs.nix

    ../../profiles/secunet.nix
    ../../profiles/bcachefs.nix
    ../../profiles/secureboot.nix

    ../../profiles/telegraf.nix
  ];

  # FIME: remove
  security.acme.defaults.server =
    builtins.trace "remove staging environment from acme"
    "https://acme-staging-v02.api.letsencrypt.org/directory";

  hardware.cpu.intel.updateMicrocode = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.initrd.supportedFilesystems = [ "bcachefs" ];

  networking.hostName = "gloin";
  networking.wireless.iwd.enable = true;

  environment.systemPackages = with pkgs; [ lm_sensors virt-manager ];

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

  nix.gc.automatic = false;

  services.openssh.settings.X11Forwarding = true;

  /* boot.kernelPatches = [{
       name = "bcachefs-lock-time";
       patch = null;
       extraConfig = ''
         BCACHEFS_LOCK_TIME_STATS y
       '';
     }];
  */

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.11";
}
