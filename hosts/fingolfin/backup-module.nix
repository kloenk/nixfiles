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
    sops.secrets."restic/ssh-key" = { owner = "root"; };
    #sops.secrets."restic/aws-env" = { owner = "root"; };

    programs.ssh = {
      knownHosts."u448103.your-storagebox.de" = {
        hostNames = [ "u448103.your-storagebox.de" "2a01:4f8:2b03:9b7::2" ];
        publicKey =
          "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
      };
    };

    systemd.services = lib.mapAttrs' (name: backup:
      nameValuePair "restic-${name}" rec {
        path = [ pkgs.openssh pkgs.restic ]
          ++ lib.optionals (backup.postgresDatabases != [ ])
          [ config.services.postgresql.package ];

        script = ''
          set -xeu pipefail
          export RESTIC_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/password-file
          #export RESTIC_REPOSITORY="s3:http://192.168.178.144:3900/usee-moodle-backup/${name}"
          export RESTIC_REPOSITORY="sftp://u448103@u448103.your-storagebox.de/moodle"
          export XDG_CACHE_HOME=/var/cache/restic-backups-${name}
          export HOME=$XDG_CACHE_HOME
          RESTIC_SFTP_ARGS="-o ControlPath=$XDG_CACHE_HOME/ssh.sock -i $CREDENTIALS_DIRECTORY/ssh-key -o MACs=hmac-sha2-512,hmac-sha2-256"
          restic unlock -o sftp.args="$RESTIC_SFTP_ARGS" || restic init -o sftp.args="$RESTIC_SFTP_ARGS"
          restic forget \
              --keep-last 10 \
              --keep-hourly 24 \
              --keep-daily 7 \
              --keep-weekly 4 \
              --keep-monthly 12 \
              --keep-yearly 10 \
              --prune \
              -o sftp.args="$RESTIC_SFTP_ARGS"
        '' + lib.concatMapStringsSep "\n" (db: ''
          pg_dump ${db} | restic backup --stdin --stdin-filename ${db}.sql -o sftp.args="$RESTIC_SFTP_ARGS"
        '') backup.postgresDatabases + (if backup.paths != [ ] then ''
          restic backup  -o sftp.args="$RESTIC_SFTP_ARGS" ${
            concatStringsSep " " backup.paths
          }
        '' else
          "") + ''
            restic check -o sftp.args="$RESTIC_SFTP_ARGS"
          '';

        restartIfChanged = false;

        serviceConfig = {
          #EnvironmentFile = "${config.sops.secrets."restic/aws-env".path}";
          LoadCredential = [
            "password-file:${config.sops.secrets."restic/password".path}"
            "ssh-key:${config.sops.secrets."restic/ssh-key".path}"
          ];
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
          RandomizedDelaySec = 60;
        };
      }) backups;
  };
}
