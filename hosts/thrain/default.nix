{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./links.nix
    ./network

    ../../profiles/postgres.nix
    ../../profiles/syncthing.nix
    ../../profiles/users/kloenk/password.nix

    ./services/mpd.nix
    ./services/syncthing.nix
    ./services/samba.nix
    ./services/proxies.nix

    ../../profiles/telegraf.nix
  ];

  hardware.cpu.intel.updateMicrocode = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;
  boot.supportedFilesystems = [ ];
  boot.initrd.supportedFilesystems = [ ];

  networking.useDHCP = false;
  networking.hostName = "thrain";
  networking.search = [ "burscheid.home.kloenk.de" ];
  networking.hosts = {
    "192.168.178.1" = lib.singleton "fritz.box";
    "192.168.178.247" = [ "elrond" "elrond.kloenk.de" ];
  };

  # allow emergency shell access without password
  boot.initrd.systemd.emergencyAccess = true;

  # initrd network
  boot.initrd.systemd.network.enable = true;
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.port = 62955;
  boot.initrd.network.ssh.hostKeys =
    [ "/persist/data/openssh/initrd_25519_key" ];

  # virtmanager
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
  services.kresd.instances = 4;

  users.users.kloenk.extraGroups = [
    "docker" # enable docker controll
    "libvirtd" # libvirtd connections
    "audio"
  ];

  fileSystems."/persist".neededForBoot = true;

  services.telegraf.extraConfig.inputs = {
    sensors = { };
    ping = {
      method = "native";
      urls = [ "1.1.1.1" "kloenk.de" ];
    };
  };
  systemd.services.telegraf.path = with pkgs; [ lm_sensors ];

  system.stateVersion = "24.05";
}
