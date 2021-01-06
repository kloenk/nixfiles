{ config, lib, pkgs, ... }:

{
  imports = [
    ./trudeltiere.nix
    ./wass-er.nix
    ./schallsignal.nix
  ];

  # remove for production
  systemd.services."acme-daten.wass-er.com".wantedBy = lib.mkForce [];
  systemd.services."acme-daten.wass-er.com".enable = false;
  systemd.services."acme-selfsigned-daten.wass-er.com".wantedBy = [ "multi-user.target" ];
  systemd.services."acme-schallsignal.wass-er.com".wantedBy = lib.mkForce [];
  systemd.services."acme-schallsignal.wass-er.com".enable = false;
  systemd.services."acme-selfsigned-schallsignal.wass-er.com".wantedBy = [ "multi-user.target" ];
  systemd.services."acme-wass-er.com".wantedBy = lib.mkForce [];
  systemd.services."acme-wass-er.com".enable = false;
  systemd.services."acme-selfsigned-wass-er.com".wantedBy = [ "multi-user.target" ];
  systemd.services."acme-trudeltiere.de".wantedBy = lib.mkForce [];
  systemd.services."acme-trudeltiere.de".enable = false;
  systemd.services."acme-selfsigned-trudeltiere.de".wantedBy = [ "multi-user.target" ];

  environment.systemPackages = with pkgs; [
    wp-cli
  ];

  services.httpd.enable = lib.mkOverride 25 false; # No thanks
  services.httpd.group = config.services.nginx.group;

  fileSystems."/var/lib/wordpress" = {
    device = "/persist/data/wordpress";
    fsType = "none";
    options = [ "bind" ];
  };
}
