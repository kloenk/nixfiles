{ config, lib, pkgs, ... }:

{
  services.factorio = {
    enable = true;
    mods = [ ];
    saveName = "multi";
    game-name = "Kloenk's factorio server";
    extraSettings = { admins = [ "Kloenk" ]; };
    autosave-interval = 5;
    game-password = "very-secure-password"; # todo move out of config
  };

  systemd.services.factorio.serviceConfig.BindPaths =
    "/persist/data/factorio:/var/lib/factorio";
  systemd.services.factorio.serviceConfig.ReadWritePaths =
    "/persist/data/factorio";

  networking.firewall.allowedUDPPorts = [ 34197 ];
}

