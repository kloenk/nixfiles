{ config, pkgs, lib, ... }:

with lib;

let
  backups = config.usee.backups;

  backupOpts = { ... }: {
    options = {

      user = mkOption {
        type = types.str;
        default = "root";
      };
      dynamicUser = mkEnableOption "use dynamic user";

      paths = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      postgresDatabases = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      certificates = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      prepareScript = mkOption {
        type = types.lines;
        default = "";
      };

    };
  };

in {

  options = {
    usee.backups = mkOption {
      type = with types; attrsOf (submodule backupOpts);
      default = { };
    };
  };

  config = mkIf (backups != { }) {
    sops.secrets."restic/password" = { owner = "root"; };
    sops.secrets."restic/aws-env" = { owner = "root"; };

    systemd.services = lib.mapAttrs' (name: backup:
      nameValuePair "restic-${name}" rec {
        path = [ pkgs.openssh pkgs.restic ]
          ++ lib.optionals (backup.postgresDatabases != [ ])
          [ config.services.postgresql.package ];

        script = ''
          set -xeu pipefail
          export RESTIC_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/password-file
          export RESTIC_REPOSITORY="s3:http://192.168.178.144:3900/usee-moodle-backup/${name}"
          export XDG_CACHE_HOME=/var/cache/restic-backups-${name}
          restic unlock || restic init
          restic forget \
              --keep-last 10 \
              --keep-hourly 24 \
              --keep-daily 7 \
              --keep-weekly 4 \
              --keep-monthly 12 \
              --keep-yearly 10 \
              --prune
        '' + lib.concatMapStringsSep "\n" (db: ''
          pg_dump ${db} | restic backup --stdin --stdin-filename ${db}.sql
        '') backup.postgresDatabases + (if backup.paths != [ ] then ''
          restic backup ${concatStringsSep " " backup.paths}
        '' else
          "") + ''
            restic check
          '';

        restartIfChanged = false;

        serviceConfig = {
          EnvironmentFile = "${config.sops.secrets."restic/aws-env".path}";
          LoadCredential =
            [ "password-file:${config.sops.secrets."restic/password".path}" ];
          Type = "oneshot";
          User = backup.user;
          DynamicUser = backup.dynamicUser;
          PrivateTmp = true;
          CacheDirectory = "restic-backups-${name}";
        };
      }) backups;

    systemd.timers = lib.mapAttrs' (name: backup:
      nameValuePair "restic-${name}" {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "0/2:10";
          RandomizedDelaySec = 0;
        };
      }) backups;
  };
}
