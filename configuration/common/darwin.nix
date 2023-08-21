{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  nix.configureBuildUsers = true;
  nix.useDaemon = true;

  documentation.enable = false;
  programs.man.enable = true;
  programs.info.enable = true;

  sops.age.generateKey = true;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  #sshKeyPaths = [ "/persist/data/openssh/ed25519_key" ];
  sops.defaultSopsFile = ../../secrets + "/${config.networking.hostName}.yaml";

  environment.systemPackages = with pkgs; [
    jq
    cmake
    bat
    skim

    #colmena

    gnupg
    pinentry_mac
  ];
}
