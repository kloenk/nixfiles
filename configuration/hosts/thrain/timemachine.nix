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
          "vol size limit" = 250000;
          "valid users" = "@users";
        };
      };
    };

    avahi = {
      ipv4 = true;
      ipv6 = true;
      enable = true;
      nssmdns = true;

      interfaces = [ "vlan1337" "eno1" ];

      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}
