{ config, pkgs, lib, ... }:

{
  imports = [
    ./node-exporter
    ./zsh
    ./pbb.nix
    ./environment.nix
  ];

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

  # initrd ssh foo
  boot.initrd.network.ssh = {
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000612029874"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNRVDZB2ID/R2S6ErIaMvmOcSNiakBgMZoPuwgzPFVuUv6xDMaOQf65viu5DoD+VvTWAJTezQYtuuxc7aUDQiQY= mac@secretive.Finn’s-MacBook-Pro.local"
    ];
    port = lib.mkDefault 62955;
  };


  # Sysbadge udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="33ff", ATTRS{idProduct}=="4025", MODE="0666"
  '';

}
