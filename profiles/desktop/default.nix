{ config, lib, ... }:

{
  imports = [
    ./applications.nix
    ./alacritty.nix
    ./wezterm.nix
    ./firefox.nix
    ./gammastep.nix
    ./sound.nix
    ../users/kloenk/password.nix
  ];

  services.nginx.virtualHosts."${config.networking.hostName}.${config.networking.domain}" =
    {
      enableACME = lib.mkForce false;
      forceSSL = lib.mkForce false;
    };
}
