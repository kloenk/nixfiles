{ config, lib, pkgs, ... }:

{
  services.restic.backups.moodle-usee = {
    initialize = true;
    passwordFile = "/var/src/secrets/restic/password";
    paths = [
      #config.services.mysqlBackup.location
      config.services.postgresqlBackup.location
      "/etc/nixos"
      "/var/lib/moodle"
    ];
    repository = "rest:http://192.168.56.1:8080/moodle-usee";
  };

  systemd.services.restic-backups-moodle-usee.path = [ pkgs.rclone ];
  systemd.services.restic-backups-moodle-usee.preStart = lib.mkBefore (''
    mkdir -p /root/.config/rclone
    ln -sf /var/src/secrets/restic/rclone.conf /root/.config/rclone/rclone.conf
  '');

  services.postgresqlBackup = {
    enable = true;
    compression = "zstd";
    databases = [ "moodle" ];
  };

  /* systemd.services.restic-backups-moodle-usee.after = [ "mysql-backup.service" ];
     systemd.services.restic-backups-moodle-usee.wants = [ "mysql-backup.service" ];
     services.mysqlBackup.enable = true;
     services.mysqlBackup.databases = [
       "moodle"
       "mysql"
     ];
  */
}
