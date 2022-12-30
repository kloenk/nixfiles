{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../default.nix
    ../../common
    ../../common/pbb.nix
    #../../desktop
    #../../desktop/sway.nix
    #../../desktop/vscode.nix
  ];

  hardware.enableRedistributableFirmware = true;

  boot.supportedFilesystems = [ "xfs" "vfat" ];
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "bilbo";
  networking.useDHCP = false;
  networking.interfaces.enp0s2.useDHCP = true;
  networking.nameservers = [ "1.1.1.1" "10.0.0.2" ];

  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  users.users.kloenk.initialPassword = "foobaar";
  users.users.kloenk.packages = with pkgs; [
    lm_sensors
    tpacpi-bat
    acpi # fixme: not in the kernel
    #wine # can we ditch it?
    python # includes python2 as dependency for vscode
    platformio # pio command
    openocd # pio upload for stlink
    stlink # stlink software
    #teamspeak_client       # team speak
  ];

  users.users.kloenk.extraGroups = [
    "dialout" # allowes serial connections
    "plugdev" # allowes stlink connection
    "davfs2" # webdav foo
  ];

  services.pcscd.enable = true;
  #services.pcscd.plugins = with pkgs; [ ccid pcsc-cyberjack ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes sayyou
  # should.
  system.stateVersion = "21.03";
}
