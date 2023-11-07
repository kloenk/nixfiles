{ lib, pkgs, config, ... }:

{
  users.users.kloenk = {
    isNormalUser = true;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000611120054"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLNxiPZehrmMebnU9HgqEHo278F1promBrgixOaHnyIrEVZ+Vd1l9AiVwTPYn1s65OfiuZ8n/Eg2rKStNOr5wBA="
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNRVDZB2ID/R2S6ErIaMvmOcSNiakBgMZoPuwgzPFVuUv6xDMaOQf65viu5DoD+VvTWAJTezQYtuuxc7aUDQiQY= mac@secretive.Finn’s-MacBook-Pro.local"
    ];

    packages = with pkgs; [
      tmux
      nload
      htop
      ripgrep
      eza
      bat
      progress
      pv
      file
      bc
      #zstd
      unzip
      jq
      neofetch
      onefetch
      sl
      tcpdump
      binutils
      nixfmt
    ];
  };
}