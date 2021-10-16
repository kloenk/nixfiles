{ pkgs, config, ... }:

{

  fileSystems."/var/lib/mysql" = {
    device = "/persist/data/mysql";
    options = [ "bind" ];
  };
  systemd.services.mysql.unitConfig.RequiresMountFor = [ "/var/lib/mysql" ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings.mysqld = {
      innodb_read_only_compressed = false;
    };
  };

  services.mysqlBackup = { enable = true; };
}
