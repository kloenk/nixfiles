{ pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [
    548 # netatalk
  ];

  services = {
    netatalk = {
      enable = true;

      volumes = {
        "kloenk-time-machine" = {
          "time machine" = "yes";
          path = "/persists/data/timemachine";
          "valid users" = "kloenk";
        };
      };
    };

    avahi = {
      enable = true;
      nssmdns = true;

      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}
