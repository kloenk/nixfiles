{ inputs, pkgs, lib, config, ... }:

{
  imports = [
    ../default.nix
    ./ssh.nix
    ./network.nix
    ./nginx.nix

    # dont work under darwin currently
    ../vim.nix
    ../zsh

    ../../users/root
    ../../users/kloenk
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
  # console.keyMap = lib.mkDefault "de"; # neo
  console.keyMap = lib.mkDefault "us";
  console.font = "Lat2-Terminus16";

  systemd.tmpfiles.rules = [
    "Q /persist 755 root - - -"
    "Q /persist/data 755 root - - -"

    "Q /persist/data/acme 750 nginx - - -"
    #"L /var/lib/acme - acme - - /persist/data/acme"
    #"L+ /etc/shadow - - - - /persist/data/shadow"
  ];
  services.resolved.dnssec = "allow-downgrade";
  networking.domain = lib.mkDefault "kloenk.de";

  # Services
  services.nginx.enable = lib.mkDefault true;

  services.journald.extraConfig = lib.mkDefault "SystemMaxUse=2G";

  ## Monitoring
  services.telegraf.extraConfig.inputs = {
    kernel = { };
    kernel_vmstat = { };
    wireguard = { };
    systemd_units = { unittype = "service,mount,socket,target"; };
  };
  systemd.services.telegraf.serviceConfig.AmbientCapabilities =
    [ "CAP_NET_ADMIN" ];

  # programs.gnupg = {
  #   agent = {
  #     enable = true;
  #     enableSSHSupport = true;
  #   };
  # };
  # TODO: certificatFiles

  # Users
  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;
  hardware.enableRedistributableFirmware = true;
  programs.mtr.enable = true;

  documentation.nixos.enable = false;

  environment.systemPackages = with pkgs; [
    alacritty.terminfo
    rxvt_unicode.terminfo
    restic
    tmux
    iptables
    bash-completion
    whois

    rclone
    wireguard-tools

    usbutils
    pciutils
  ];

  # Deployment
  deployment.tags =
    [ pkgs.stdenv.hostPlatform.system config.networking.domain ];
  deployment.targetUser = lib.mkDefault "kloenk";
  deployment.targetHost = lib.mkDefault config.networking.fqdn;
  deployment.targetPort =
    lib.mkDefault (lib.head config.services.openssh.ports);

}
