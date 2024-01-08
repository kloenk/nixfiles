{ ... }:

{
  services.syncthing = {
    settings = {
      devices = {
        thrain = {
          id =
            "H3O3OPV-XMB6Y2W-GE3KINS-U7N6Q2U-VSBTRBX-NWPTDYV-5TMAUB3-T7J6BQX";
        };
        frodo = {
          id =
            "AHVY7YB-PIQ24ZI-FX7ZAMC-XFNBSHF-57AWZF6-S76V6G5-5UXGOJV-BWNJYAW";
        };
        elrond = {
          id =
            "YAHWJOS-HXERGLI-3RKPLGH-NNIQJ2J-BH3HA3M-FQJJCWW-L57SCXD-Y4MTWQN";
        };
      };

      folders = {
        "~/Developer" = {
          label = "Developer";
          id = "projects";
          devices = [ "thrain" "frodo" "elrond" ];
        };
      };
    };
  };
}
