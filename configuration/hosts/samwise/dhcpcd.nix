{ pkgs, lib, ... }:

{
  networking.firewall.allowedUDPPorts = [ 67 68 ];

  fileSystems."/var/lib/dhcpd" = {
    device = "/persist/data/dhcpd";
    fsType = "none";
    options = [ "bind" ];
  };

  services.dhcpd4 = {
    enable = true;
    interfaces = [ "dtag0" ];
    extraConfig = ''
      default-lease-time 600;
      max-lease-time 7200;
      authoritative;

      subnet 192.168.188.0 netmask 255.255.255.0 {
        range 192.168.188.10 192.168.188.230;
        option routers 192.168.188.1;
        option domain-name-servers 192.168.188.1;
        allow unknown-clients;
      }
    '';
  };

  #systemd.services.dhcpd4.wantedBy = lib.mkForce [ ];
}
