{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../profiles/users/kloenk/password.nix
  ];

  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  hardware.asahi.setupAsahiSound = true;

  zramSwap = {
    enable = true;
    memoryPercent = 200;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = lib.mkForce "keep";
  boot.initrd.luks.devices.cryptroot.allowDiscards = true;

  boot.supportedFilesystems = [ "nfs" ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  users.users.kloenk.extraGroups = [ "bluetooth" "scanner" "lp" ];

  systemd.network.networks."50-dhcp" = {
    name = "e* w*";
    DHCP = "yes";
  };

  networking.useDHCP = false;
  networking.hostName = "underhill";
  networking.wireless.enable = true;
  networking.wireless.interfaces = [ "wlp1s0f0" ];
  #secretFiles.secrets."desktop/wpa_supplicant.conf" = {};
  #environment.etc."wpa_supplicant.conf".source = config.secretFiles.secrets."desktop/wpa_supplicant.conf".path;

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 10;
    percentageAction = 5;
  };

  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=1 swap_opt_cmd=1

  '';
  # options snd_soc_macaudio please_blow_up_my_speakers=1
  boot.kernelModules = [ "hid-apple" ];
  boot.kernelParams = [ "apple_dcp.show_notch=1" ];

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  systemd.services.upower.wantedBy = lib.mkForce [ "multi-user.target" ];

  system.stateVersion = "25.11";
}
