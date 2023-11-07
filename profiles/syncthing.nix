{ lib, config, ... }:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    dataDir = lib.mkDefault "/persist/data/syncthing/data";
    configDir = lib.mkDefault "/persist/data/syncthing/conf";
  };

  users.users.kloenk.extraGroups = [ "syncthing" ];
}
