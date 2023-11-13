{ lib, config, ... }:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    dataDir = lib.mkDefault "/home/kloenk/.syncthing";
    configDir = lib.mkDefault "${config.services.syncthing.dataDir}/conf";
    user = "kloenk";
    group = "users";
  };

  users.users.kloenk.extraGroups = [ "syncthing" ];
}

