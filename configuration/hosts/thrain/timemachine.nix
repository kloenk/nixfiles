{ pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [
    548 # netatalk
    427 # slp
    201 # at-rtmp
    202 # at-nbp
    204 # at-echo
    206 # at-zis
  ];
  networking.firewall.allowedUDPPorts = [
    548 # netatalk
    427 # slp
    201 # at-rtmp
    202 # at-nbp
    204 # at-echo
    206 # at-zis
  ];

  services = {
    netatalk = {
      enable = true;

      extraConfig = lib.mkBefore (''
        hosts allow = 192.168.178.0/24 6.0.2.0/24
        uam list = uams_guest.so
        log level = default:debug
      '');

      volumes = {
        "kloenk-time-machine" = {
          "time machine" = "yes";
          path = "/persist/data/timemachine";
          "rwlist" = "nobody";
          "vol size limit" = 250000;
          "valid users" = "@users";
          "smb2 max credits" = 16384;
        };
      };
    };

    avahi = {
      ipv4 = true;
      ipv6 = true;
      enable = true;
      nssmdns = true;

      interfaces = [ "vlan1337" "br0" ];

      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}
