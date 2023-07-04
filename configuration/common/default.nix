{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ./nginx
    ./nginx/kloenk.nix
    ./node-exporter
    ./zsh
    ./make-nixpkgs.nix
    ./kloenk.nix
    ./pbb.nix
    ./initrd.nix
    ./environment.nix
  ];

  # environment.etc."src/nixpkgs".source = config.sources.nixpkgs;
  #  environment.etc."src/nixos-config".text = ''
  #      ((import (fetchTarball "https://github.com/kloenk/nix/archive/master.tar.gz") { }).configs.${config.networking.hostName})
  #  '';
  #  environment.variables.NIX_PATH = lib.mkOverride 25 "/etc/src";

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # zfs
  boot.zfs.enableUnstable = true; # allow linuxPackages_latest with zfs
  boot.kernelParams =
    [ "nohibernate" ]; # https://github.com/openzfs/zfs/issues/260

  nix.settings.system-features =
    [ "recursive-nix" "kvm" "nixos-test" "big-parallel" ];

  system.autoUpgrade.flake = "kloenk";

  # TODO: what works in common?
  networking.domain = lib.mkDefault "kloenk.de";
  networking.useNetworkd = lib.mkDefault true;
  networking.search = [ "kloenk.de" ];
  networking.extraHosts = ''
    127.0.0.1 ${config.networking.hostName}.kloenk.de
  '';
  networking.useDHCP = lib.mkDefault false;
  networking.interfaces.lo = lib.mkDefault {
    ipv4.addresses = [
      {
        address = "127.0.0.1";
        prefixLength = 8;
      }
      {
        address = "127.0.0.53";
        prefixLength = 32;
      }
    ];
  };

  # ssh
  services.openssh = {
    enable = true;
    ports = [ 62954 ];
    settings.PasswordAuthentication = lib.mkDefault
      (if (config.networking.hostName != "kexec") then false else true);
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = lib.mkDefault "prohibit-password";

    hostKeys = [{
      path = "/persist/data/openssh/ed25519_key";
      type = "ed25519";
    }];

    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };
  sops.age.sshKeyPaths = [ "/persist/data/openssh/ed25519_key" ];
  sops.defaultSopsFile = ../../secrets + "/${config.networking.hostName}.yaml";

  # monitoring
  services.vnstat.enable = lib.mkDefault true;
  # programs.sysdig.enable = lib.mkDefault true;
  security.sudo.wheelNeedsPassword = false;

  nftables.enable = true;
  nftables.forwardPolicy = lib.mkDefault "drop";

  services.journald.extraConfig = "SystemMaxUse=2G";

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  #console.keyMap = lib.mkDefault "neo";
  console.keyMap = lib.mkDefault "de";
  console.font = "Lat2-Terminus16";

  environment.systemPackages = with pkgs; [
    #termite.terminfo
    kitty.terminfo
    alacritty.terminfo
    rxvt_unicode.terminfo
    restic
    tmux
    iptables
    bash-completion
    whois
    qt5.qtwayland

    erlang # for escript scripts
    rclone
    wireguard-tools
    nushell

    usbutils
    pciutils
    git
  ];

  environment.variables.EDITOR = "vim";

  users.users.kloenk.shell = lib.mkOverride 75 pkgs.zsh;

  #programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.mtr.enable = true;

  #users.users.root.shell = pkgs.fish;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000612029874"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNRVDZB2ID/R2S6ErIaMvmOcSNiakBgMZoPuwgzPFVuUv6xDMaOQf65viu5DoD+VvTWAJTezQYtuuxc7aUDQiQY= mac@secretive.Finn’s-MacBook-Pro.local"
  ];

  # initrd ssh foo
  boot.initrd.network.ssh = {
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000612029874"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNRVDZB2ID/R2S6ErIaMvmOcSNiakBgMZoPuwgzPFVuUv6xDMaOQf65viu5DoD+VvTWAJTezQYtuuxc7aUDQiQY= mac@secretive.Finn’s-MacBook-Pro.local"
    ];
    port = lib.mkDefault 62955;
  };

  systemd.tmpfiles.rules = [
    "Q /persist 755 root - - -"
    "Q /persist/data 755 root - - -"

    "Q /persist/data/acme 750 nginx - - -"
    #"L /var/lib/acme - acme - - /persist/data/acme"
    #"L+ /etc/shadow - - - - /persist/data/shadow"
  ];
  services.resolved.dnssec = "false";

  services.telegraf.extraConfig.inputs = {
    kernel = { };
    kernel_vmstat = { };
    wireguard = { };
    systemd_units = { unittype = "service,mount,socket,target"; };
  };
  systemd.services.telegraf.serviceConfig.AmbientCapabilities =
    [ "CAP_NET_ADMIN" ];

  documentation.nixos.enable = false;
}
