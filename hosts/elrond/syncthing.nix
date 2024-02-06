{ ... }:

{
  services.syncthing = {
    settings = {
      devices = {
        thrain = {
          addresses = [ "tcp://192.168.178.248" "tcp://192.168.242.101" ];
          id =
            "H3O3OPV-XMB6Y2W-GE3KINS-U7N6Q2U-VSBTRBX-NWPTDYV-5TMAUB3-T7J6BQX";
        };
        frodo = {
          id =
            "AHVY7YB-PIQ24ZI-FX7ZAMC-XFNBSHF-57AWZF6-S76V6G5-5UXGOJV-BWNJYAW";
        };
        gloin = {
          id =
            "XOJ2TU6-WZOWWYY-GU5O7LF-LLDZWYZ-JGAIHTH-SFAWOBJ-SM4L644-TZRFQQY";
        };
      };

      folders = {
        "~/Developer" = {
          label = "Developer";
          id = "projects";
          devices = [ "thrain" "frodo" "gloin" ];
        };
        "~/Uni" = {
          label = "Uni";
          id = "uni";
          devices = [ "thrain" "frodo" ];
        };
      };
    };
  };
}
