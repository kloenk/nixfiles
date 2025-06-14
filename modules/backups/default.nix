{ config, pkgs, lib, ... }:

with lib;

let
  backups = config.backups;

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
      btrfsSubvolumes = mkOption {
        type = with types; attrsOf str;
        default = { };
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
    backups = mkOption {
      type = with types; attrsOf (submodule backupOpts);
      default = { };
    };
  };

  config = mkIf (backups != { }) {
    sops.secrets."restic/password" = {
      owner = "root";
      sopsFile = ../../secrets/shared/backups.yaml;
    };
    sops.secrets."restic/aws-env" = {
      owner = "root";
      sopsFile = ../../secrets/shared/backups.yaml;
    };

    systemd.services = lib.mapAttrs' (name: backup:
      nameValuePair "restic-${name}" rec {
        path = [ pkgs.openssh pkgs.restic ]
          ++ lib.optionals (backup.postgresDatabases != [ ])
          [ config.services.postgresql.package ];

        script = ''
          set -xeu pipefail
          export RESTIC_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/password-file
          export RESTIC_REPOSITORY="s3:https://garage3.cyberchaos.dev/kloenk-restic/${name}"
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
          "") + (lib.optionalString (backup.btrfsSubvolumes != { }) ''
            restic backup btrfs
          '') + ''
            restic check
          '';

        restartIfChanged = false;

        serviceConfig = let
          pre-start-btrfs = pkgs.writeShellScript "pre-start-btrfs" (''
            mkdir -p btrfs
          '' + lib.concatStringsSep "\n" (lib.mapAttrsToList
            (volume: snapshot: ''
              ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r ${volume} ${snapshot}
            '') backup.btrfsSubvolumes));
          post-stop-btrfs = pkgs.writeShellScript "post-stop-btrfs"
            "btrfs subvolume delete ${
              (lib.concatMapStringsSep " " (snapshot: "btrfs/${snapshot}")
                (lib.attrValues backup.btrfsSubvolumes))
            }";
        in {
          EnvironmentFile = "${config.sops.secrets."restic/aws-env".path}";
          LoadCredential =
            [ "password-file:${config.sops.secrets."restic/password".path}" ];
          Type = "oneshot";
          User = backup.user;
          DynamicUser = backup.dynamicUser;
          PrivateTmp = true;
          CacheDirectory = "restic-backups-${name}";
          PreStartExec = [ "!${pre-start-btrfs}" ];
          PostStopExec = [ "!${post-stop-btrfs}" ];
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
