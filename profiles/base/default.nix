{ config, pkgs, ... }:

{
  imports = [ ./nix.nix ./zsh ./ssh.nix ./git.nix ./helix.nix ./nushell ];

  time.timeZone = "Europe/Berlin";
  security.pki.certificateFiles = [ ../../lib/kloenk-int-ca.crt ];

  environment.systemPackages = with pkgs; [ eza fd ripgrep htop cyme ];

  sops.defaultSopsFile = ../../secrets + "/${config.networking.hostName}.yaml";
}
