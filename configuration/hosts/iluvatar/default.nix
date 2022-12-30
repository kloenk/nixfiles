{ config, pkgs, lib, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ./wireguard.nix

    ./bitwarden.nix
    ./postgres.nix
    ./website.nix

    #./mysql.nix

    ./coredns.nix

    ../../common/telegraf.nix
  ];

  # vm connection
  services.qemuGuest.enable = true;

  boot.supportedFilesystems = [ "vfat" "xfs" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "iluvatar";
  networking.domain = "kloenk.dev";
  networking.nameservers = [
    "2001:470:20::2"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
    "1.1.1.1"
  ];
  networking.extraHosts = # FIXME: replace with ’networking.hosts‘
    ''
      127.0.0.1 iluvatar.kloenk.dev
    '';


  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.enp1s0.tempAddress = "disabled";

  # running bind/coredn
  services.resolved.enable = false;

  nix.gc.automatic = true;
  users.users.root.initialPassword = "foobar";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.05";
}