{ pkgs, lib, ... }:

{
  networking.firewall.allowedUDPPorts = [ 67 68 ];

  fileSystems."/var/lib/dhcp" = {
    device = "/persist/data/dhcp";
    fsType = "none";
    options = [ "bind" ];
  };

  services.dhcpd4 = {
    enable = true;
    interfaces = [ "eno1" ];
    extraConfig = ''
      default-lease-time 600;
      max-lease-time 7200;
      authoritative;

      subnet 192.168.178.0 netmask 255.255.255.0 {
        range 192.168.178.10 192.168.178.230;
        option routers 192.168.178.2;
        option domain-name-servers 192.168.178.2;
        allow unknown-clients;
      }
    '';
  };

  #systemd.services.dhcpd4.wantedBy = lib.mkForce [ ];
}
