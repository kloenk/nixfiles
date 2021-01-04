{ config, lib, pkgs, ... }:

{
  fileSystems."/var/lib/mysql" = {
    device = "/persist/data/mysql/";
    fsType = "none";
    options = [ "bind" ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  environment.systemPackages = with pkgs; [ mariadb ];
}
