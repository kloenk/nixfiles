{ lib, config, ... }:

{
  k.syncthing = {
    enable = true;

    devices = {
      thrain =
        "H3O3OPV-XMB6Y2W-GE3KINS-U7N6Q2U-VSBTRBX-NWPTDYV-5TMAUB3-T7J6BQX";
      frodo = "G6WVUXF-MN6NJX4-EXGUY7W-Z457F2E-ONS7Q7D-6TT7OWN-4IUVKUO-QP62UAE";
      elrond =
        "YAHWJOS-HXERGLI-3RKPLGH-NNIQJ2J-BH3HA3M-FQJJCWW-L57SCXD-Y4MTWQN";
      gloin = "Z2CIYQ5-5CPAXKW-UPRYJ2W-C26HN75-2PMWOLP-7NA43FY-GBCUAU5-SNT6JA6";
    };

    folders = {
      "projects" = {
        path = lib.mkDefault "~/Developer";
        devices = "hosts";
      };
      /* "uni" = {
           path = lib.mkDefault "~/Uni";
           #devices = [ "thrain" "frodo" ]; # TODO: host tag system?
         };
      */
    };
  };
}
