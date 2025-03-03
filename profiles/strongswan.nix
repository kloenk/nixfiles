{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ strongswan ];

  networking.firewall.allowedUDPPorts = [ 500 4500 ];

  services.strongswan-swanctl = { enable = true; };

  systemd.tmpfiles.rules = [
    "L+ /etc/swanctl/x509/ca.cert.pem - - - - ${../lib/kloenk-ca.cert.pem}"
    "L+ /etc/swanctl/x509/vpn.cert.pem - - - - ${../lib/kloenk-vpn.cert.pem}"
    "L+ /etc/swanctl/private/key.pem - - - - ${
      config.sops.secrets."vpn/key.pem".path
    }"
  ];

  /* users.users.strongswan = {
       isSystemUser = true;
       group = "strongswan";
     };
     users.groups.strongswan = { };

     systemd.services.strongswan-swanctl = {
       serviceConfig = {
         capabilities = [
           "CAP_NET_BIND_SERVICE"
           "CAP_AUDIT_WRITE"
           "CAP_NET_RAW"
           "CAP_NET_ADMIN"
         ];
         User = "strongswan";
         Group = "strongswan";
       };
     };
  */

  systemd.network.config.routeTables = { strongswan = 220; };

  sops.secrets = { "vpn/key.pem".owner = "root"; };
}
