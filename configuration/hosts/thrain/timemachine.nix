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
          "valid users" = "kloenk";
          #"rwlist" = "nobody";
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
