{ config, lib, ... }:

{
  imports = [
    ./applications.nix
    ./alacritty.nix
    ./firefox.nix
    ./gammastep.nix
    ./syncthing.nix
    ./sound.nix
  ];

  services.nginx.virtualHosts."${config.networking.hostName}.${config.networking.domain}" =
    {
      enableACME = lib.mkForce false;
      forceSSL = lib.mkForce false;
    };

}
