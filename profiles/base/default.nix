{ config, pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./ssh.nix
    ./git.nix
    ./helix.nix # ./nushell.nix
  ];

  time.timeZone = "Europe/Berlin";
  security.pki.certificateFiles = [ ../../lib/kloenk-int-ca.crt ];

  environment.systemPackages = with pkgs; [ eza fd ripgrep htop ];

  sops.defaultSopsFile = ../../secrets + "/${config.networking.hostName}.yaml";
}
