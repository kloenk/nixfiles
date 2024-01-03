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
      };

      folders = {
        "~/Developer" = {
          label = "Developer";
          id = "projects";
          devices = [ "thrain" ];
        };
      };
    };
  };
}
