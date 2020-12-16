{ pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [
    548 # netatalk
  ];
  networking.firewall.allowedUDPPorts = [
    548 # netatalk
  ];

  services = {
    netatalk = {
      enable = true;

      extraConfig = lib.mkBefore (''
        hosts allow = 192.168.178.0/24 6.0.2.0/24
      '');

      volumes = {
        "kloenk-time-machine" = {
          "time machine" = "yes";
          path = "/persists/data/timemachine";
          #"rwlist" = "nobody";
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
