{ config, ... }:

{
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  services.syncthing = {
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
        frodo = {
          id =
            "AHVY7YB-PIQ24ZI-FX7ZAMC-XFNBSHF-57AWZF6-S76V6G5-5UXGOJV-BWNJYAW";
        };
        gloin = {
          id =
            "Z2CIYQ5-5CPAXKW-UPRYJ2W-C26HN75-2PMWOLP-7NA43FY-GBCUAU5-SNT6JA6";
        };
      };

      folders = {
        "projects" = {
          id = "projects";
          label = "Developer";
          path = "/persist/data/syncthing/data/projects";
          devices = [ "elrond" "frodo" "gloin" ];
        };
        "Uni" = {
          id = "uni";
          label = "Uni";
          path = "/persist/data/syncthing/data/uni";
          devices = [ "elrond" "frodo" ];
        };
      };
    };
  };

  users.users.kloenk.extraGroups = [ "syncthing" ];
}
