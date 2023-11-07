{ ... }:

{
  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000612029874"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNRVDZB2ID/R2S6ErIaMvmOcSNiakBgMZoPuwgzPFVuUv6xDMaOQf65viu5DoD+VvTWAJTezQYtuuxc7aUDQiQY= mac@secretive.Finns-MacBook-Pro.local"
    ];
  };
}