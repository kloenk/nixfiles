{ config, ... }:

{
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    dataDir = "/persist/data/syncthing";
    configDir = "${config.services.syncthing.dataDir}";
    user = "kloenk";
    group = "users";

    settings = {
      options.urAccepted = -1;
      devices = {
        elrond = {
          addresses = [ "tcp://192.168.178.247" "tcp://192.168.242.204" ];
          id =
            "YAHWJOS-HXERGLI-3RKPLGH-NNIQJ2J-BH3HA3M-FQJJCWW-L57SCXD-Y4MTWQN";
        };
      };

      folders = {
        "projects" = {
          id = "projects";
          label = "Developer";
          path = "/persist/data/syncthing/data/projects";
          devices = [ "elrond" ];
        };
      };
    };
  };

  users.users.kloenk.extraGroups = [ "syncthing" ];
}
