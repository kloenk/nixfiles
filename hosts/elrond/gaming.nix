{ config, pkgs, lib, ... }:

{
  users.users.kloenk.packages = with pkgs; [
    prismlauncher
    steam-run-native
    wineWowPackages.staging

    lutris
    gamescope

    discord
    xonotic

    # OBS
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vkcapture
        obs-tuna
      ];
    })
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  networking.firewall.allowedTCPPorts = [ 4455 ];

  fileSystems."/persist/Mac" = {
    device = "192.168.178.248:/Mac";
    fsType = "nfs";
  };
}
