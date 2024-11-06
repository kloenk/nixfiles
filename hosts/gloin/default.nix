{ config, pkgs, lib, ... }:

{
  imports = [
    ./disko.nix
    ./links.nix
    ./links-gwp.nix
    ./pipewire.nix
    ./evremap.nix
    ./kea.nix
    ./secureboot.nix

    ../../profiles/desktop
    ../../profiles/desktop/sway
    ../../profiles/desktop/plymouth.nix
    ../../profiles/desktop/autologin.nix
    ../../profiles/desktop/pam_u2f.nix

    ../../profiles/secunet.nix
    ../../profiles/syncthing.nix
    #../../profiles/bcachefs.nix
    #../../profiles/secureboot.nix

    ../../profiles/telegraf.nix
  ];

  hardware.cpu.intel.updateMicrocode = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.supportedFilesystems = [ "btrfs" "xfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" "xfs" ];
  #boot.loader.systemd-boot.bootCounting.enable = true;

  # FIXME: remove
  boot.initrd.systemd.emergencyAccess = true;
  k.security.pam_u2f.keys.kloenk = [
    "00ARgrKMoRvH9KYp1NYqcB0ESBgTpvjBoJGCpUNuD5eRLBUMy7ly4/ml21c0pM0JJ2MHSL1HVrcBYasRNhf1ow==,W78vHP7PIvR3WfwQfH4M4Ivp1TRh0QRi2scvTYLfQnSScAReDIMZt6T1VrWsPyDWOFp0tI4fuuhwmkZISppxPQ==,es256,+presence"
  ];

  networking.hostName = "gloin";
  networking.wireless.iwd.enable = true;

  environment.systemPackages = with pkgs; [ lm_sensors virt-manager mosh ];

  # virtmanager
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    allowedBridges = [ "br0" ];
  };

  users.users.kloenk.extraGroups = [
    "docker" # enable docker controll
    "libvirtd" # libvirtd connections
    "audio"
    "pipewire"
    "dialout" # usb serial adapter
  ];

  # smartcard
  services.pcscd.enable = true;
  services.telegraf.extraConfig.inputs = { sensors = { }; };
  systemd.services.telegraf.path = with pkgs; [ lm_sensors ];

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

  services.udev.extraRules = ''
    # Make an RP2040 in BOOTSEL mode writable by all users, so you can `picotool`
    # without `sudo`. 
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", MODE="0666"

    # Symlink an RP2040 running MicroPython from /dev/pico.
    #
    # Then you can `mpr connect $(realpath /dev/pico)`.
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0005", SYMLINK+="pico"

    #picoprobe
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", MODE="0666"

    # sysbadge (nyantec)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="33ff", MODE="0666"

    #after adding this execute
    # sudo udevadm control --reload-rules &&  sudo udevadm trigger 
    # connect and disconnetc the USB device
  '';

  services.dbus.packages = [ "/tmp/cfg/kloenk" ];

  #services.syncthing.settings.folders."uni".enable = false;

  # secrets on there
  fileSystems."/persist".neededForBoot = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.11";
}
