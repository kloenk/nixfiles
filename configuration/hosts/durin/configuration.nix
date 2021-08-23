{ lib, pkgs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../common
  ];

  # FIME: remove
  security.acme.server = builtins.trace "remove staging environment from acme"
    "https://acme-staging-v02.api.letsencrypt.org/directory";

  hardware.cpu.intel.updateMicrocode = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "none";
  #boot.loader.grub.enable = false;
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = ''
    options kvm-intel nested=1
  '';

  networking.useDHCP = false;
  networking.hostName = "durin";
  networking.domain = "kloenk.dev";
  networking.hosts = {
    "192.168.178.1" = lib.singleton "fritz.box";
    "172.16.0.1" = lib.singleton "airlink.local";
    "192.168.178.248" = [ "thrain" "thrain.kloenk.dev" "thrain.fritz.box" ];
    # TODO: barahir
    # TODO: kloenkX?
  };
  networking.interfaces.eno1.useDHCP = true;

  boot.initrd.luks.reusePassphrases = true;
  boot.initrd.luks.devices.cryptRoot.device =
    "/dev/disk/by-path/pci-0000:3a:00.0-nvme-1-part1";

  # initrd ssh server
  boot.initrd.network.enable = true;
  boot.initrd.availableKernelModules = [ "e1000e" ];
  boot.initrd.network.ssh = {
    enable = true;
  };

  /*
  boot.initrd.preLVMCommands = lib.mkBefore (''
    ip li set eno1 up
    ip addr add 192.168.178.249/24 dev eno1 && hasNetwork=1
  '');
  */

  services.openssh.extraConfig = ''
    StreamLocalBindUnlink yes
  '';

  networking.nameservers = [ "192.168.178.248" "1.1.1.1" "2001:4860:4860::8888" ];
  networking.search = [ "fritz.box" ];

  kloenk.transient.enable = true;

  environment.systemPackages = with pkgs; [ lm_sensors ];

  users.users.kloenk.home = "/persist/data/kloenk";

  system.autoUpgrade.enable = true;

  services.nginx.virtualHosts."thrain.fritz.box" = {
    locations."/public/".alias = "/persist/data/public/";
    locations."/public/".extraConfig = "autoindex on;";
  };

  # smartcard
  services.pcscd.enable = true;

  system.stateVersion = "21.11";
}