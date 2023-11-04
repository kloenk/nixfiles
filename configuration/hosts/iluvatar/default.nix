{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./wireguard.nix

    ./bitwarden.nix
    ./postgres.nix
    ./website.nix
    ./akkoma.nix

    #./mysql.nix
    # ./vh3.nix

    ./atuin.nix
    ./fleet_bot.nix
    ./jlly.nix
    ./p3tr.nix

    ./monitoring
    ./kuma.nix

    ../../common/telegraf.nix
    # ../../common/nushell.nix # FIXME: breaks ncsd
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

  systemd.network.networks."40-enp1s0" = {
    name = "enp1s0";
    addresses = [
      { addressConfig.Address = "2a01:4f8:c012:b874::/64"; }
      { addressConfig.Address = "5.75.216.37/32"; }
    ];
    routes = [{ routeConfig.Gateway = "fe80::1"; }];
  };

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
