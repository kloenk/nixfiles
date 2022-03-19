{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./links.nix
    #./mysql.nix
    ./dhcpcd.nix
    #./dns.nix

    ../../default.nix
    ../../common
    #../../common/syncthing.nix
    ../../desktop
    ../../desktop/sway.nix
    #../../desktop/vscode.nix
  ];

  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.logind.lidSwitchDocked = "ignore";
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  boot.supportedFilesystems = [ "xfs" "vfat" ];
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.availableKernelModules = [ "i915" ];
  boot.initrd.luks.reusePassphrases = true;
  boot.initrd.luks.devices."cryptRoot".device =
    "/dev/disk/by-uuid/07e84a85-0386-4696-b8ea-a7c82cfd275d";
  boot.initrd.luks.devices."cryptRoot".allowDiscards = true;

  systemd.services.coreboot-battery-treshold = {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ ectool ];
    script = ''
      ectool -w 0xb0 -z 0x46
      ectool -w 0xb1 -z 0x5a
    '';
  };
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    # freeze options
    "cgroup_no_v1=all"
  ];

  /*boot.kernelPatches = [
    {
      name = "nl80211-reload";
      patch = ./0001-nl80211-reset-regdom-when-reloading-regdb.patch;
      extraStructuredConfig = with lib.kernel; {
        EXPERT = yes;
        CFG80211_CERTIFICATION_ONUS = yes;
        CFG80211_REQUIRE_SIGNED_REGDB = no;
      };
    }
    {
      name = "nl80211-reload-remove";
      patch = ./0001-nl80211-remove-reload-flag-from-regulatory_request.patch;
    }
  ];*/


  kloenk.transient.vgroup = "ssd";
  kloenk.transient.enable = true;

  systemd.tmpfiles.rules = [
    "Q /persist/data/bluetooth 750 - - - -"
    "L /var/lib/bluetooth - - - - /persist/data/bluetooht"
  ];

  networking.hostName = "samwise";
  networking.useDHCP = false;
  networking.wireless.enable = true;
  networking.wireless.interfaces = [ "wlp2s0" ];
  networking.supplicant.wlp2s0.configFile.path = config.sops.secrets."wpa_supplicant".path;
  sops.secrets.wpa_supplicant.owner = "root";
  #networking.wireless.userControlled.enable = true;
  networking.nameservers = [ "1.1.1.1" "10.0.0.2" ];

  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;

  services.printing.browsing = true;
  services.printing.enable = true;
  services.avahi.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  environment.systemPackages = with pkgs; [
    #spice_gtk
    #ebtables
    #davfs2
    #geogebra
    #gtk-engine-murrine
    #tango-icon-theme
    #breeze-icons
    #gnome3.adwaita-icon-theme
  ];

  services.tlp.enable = true;

  users.users.kloenk.initialPassword = "foobaar";
  users.users.kloenk.packages = with pkgs; [
    lm_sensors
    tpacpi-bat
    acpi # fixme: not in the kernel
    #wine # can we ditch it?
    #spotifywm # spotify fixed for wms
    python # includes python2 as dependency for vscode
    #platformio # pio command
    #openocd # pio upload for stlink
    #stlink # stlink software
    #teamspeak_client       # team speak

    # steam
    #steam
    #steamcontroller

    # minecraft
    #multimc

    # docker controller
    #docker
    #virtmanager

    # paint software
    #krita
    #sublime3
    wpa_supplicant_gui
  ];

  # docker fo
  #virtualisation.docker.enable = true;

  #virtualisation.libvirtd = {
  #  enable = true;
  #  onShutdown = "shutdown";
  #};

  users.users.kloenk.extraGroups = [
    "dialout" # allowes serial connections
    "plugdev" # allowes stlink connection
    "davfs2" # webdav foo
    "docker" # docker controll group
    "libvirtd" # libvirt group
  ];

  # Change home dir
  users.users.kloenk.home = "/persist/data/kloenk";

  services.udev.packages = [ pkgs.openocd ];

  services.pcscd.enable = true;
  #services.pcscd.plugins = with pkgs; [ ccid pcsc-cyberjack ];

  #hardware.bluetooth.enable = true;

  # add bluetooth sink
  #hardware.bluetooth.config.General.Enable = ''
  #  Source,Sink,Media,Socket
  #'';
  #hardware.pulseaudio.zeroconf.discovery.enable = true;

  nix.gc.automatic = false;

  services.prometheus.exporters.node.enabledCollectors = [ "tcpstat" "wifi" ];

  services.syncthing.dataDir = "/persist/syncthing/";
  #systemd.homed.enable = true;

  home-manager.users.kloenk.wayland.windowManager.sway.config.output."LVDS-1".transform = "180";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes sayyou
  # should.
  system.stateVersion = "21.05";
}
