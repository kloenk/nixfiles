{ config, ... }:

{
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  services.syncthing = {
    openDefaultPorts = true;
    dataDir = "/persist/data/syncthing";
    configDir = "${config.services.syncthing.dataDir}";
  };

  k.syncthing = {
    folders."projects".path = "/persist/data/syncthing/data/projects";
    #folders."uni".path = "/persist/data/syncthing/data/uni";
  };

  users.users.kloenk.extraGroups = [ "syncthing" ];
}
