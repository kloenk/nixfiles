{ pkgs, lib, ... }:

{
  fileSystems."/var/lib/postgresql" = {
    device = "/persist/data/postgresql";
    fsType = "none";
    options = [ "bind" ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
  };

  # TODO:
  # services.postgresqlBackup.enable = true;
}
