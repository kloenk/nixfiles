{ inputs, pkgs, lib, config, ... }:

{
  imports = [
    ../default.nix
    ./ssh.nix
    ./network.nix
    ./nginx.nix

    # dont work under darwin currently
    ../ssh.nix
    ../vim.nix
    ../git.nix
  ];

  # Boot
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  ## zfs
  boot.zfs.enableUnstable = true; # allow linuxPackages_latest with zfs
  boot.kernelParams =
    [ "nohibernate" ]; # https://github.com/openzfs/zfs/issues/260

  # System
  system.autoUpgrade.flake = "kloenk";
  nix.settings.system-features =
    [ "recursive-nix" "kvm" "nixos-test" "big-parallel" ];

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "de"; # neo
  console.font = "Lat2-Terminus16";

  systemd.tmpfiles.rules = [
    "Q /persist 755 root - - -"
    "Q /persist/data 755 root - - -"

    "Q /persist/data/acme 750 nginx - - -"
    #"L /var/lib/acme - acme - - /persist/data/acme"
    #"L+ /etc/shadow - - - - /persist/data/shadow"
  ];
  services.resolved.dnssec = "false";

  # Services
  services.nginx.enable = lib.mkDefault true;

  services.journald.extraConfig = "SystemMaxUse=2G";

  ## Monitoring
  services.telegraf.extraConfig.inputs = {
    kernel = { };
    kernel_vmstat = { };
    wireguard = { };
    systemd_units = { unittype = "service,mount,socket,target"; };
  };
  systemd.services.telegraf.serviceConfig.AmbientCapabilities =
    [ "CAP_NET_ADMIN" ];


  # TODO: certificatFiles

  # Users
  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;
  hardware.enableAllFirmware = true;

  documentation.nixos.enable = false;

  # Deployment
  deployment.tags = [ pkgs.stdenv.hostPlatform.system config.networking.domain ];
  deployment.targetUser = lib.mkDefault "kloenk";
  deployment.targetHost = lib.mkDefault config.networking.fqdn;
  deployment.targetPort = lib.mkDefault (lib.head config.services.openssh.ports);

}