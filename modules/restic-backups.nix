{ options, config, pkgs, lib, ... }:

with lib;

let
  backups = config.restic-backups;

  targetOpts = { ... }: {
    options = {
      user = mkOption { type = with types; nullOr str; };
      passwordFile = mkOption { type = with types; nullOr path; };
      hostname = mkOption { type = types.str; };
      protocol = mkOption {
        type = types.str;
        default = "rest:https";
      };
      repoPath = mkOption {
        type = with types; nullOr str;
        default = null;
        # Using default text soely for documentation purpose. Since this has no knoweledge of the backupOpts it is placed in
        # this default needs to be set when we construct the script. Thats also why default=null is here.
        defaultText = "''${config.networking.hostname}-${backup-name}";
      };
    };
  };

  backupOpts = { ... }: {
    options = {

      user = mkOption {
        type = types.str;
        default = "root";
      };

      passwordFile = mkOption { type = types.str; };

      paths = mkOption {
        type = with types; listOf str;
        default = [ ];
      };

      postgresDatabases = mkOption {
        type = with types; listOf str;
        default = [ ];
      };

      targets = mkOption { type = with types; listOf (submodule targetOpts); };

      timerSpec = mkOption {
        type = types.str;
        default = "daily";
      };

    };
  };

  getPasswordFiles = backupCfg:
    (filter (el: el != null)
      (map (targetCfg: targetCfg.passwordFile) backupCfg.targets))
    ++ [ backupCfg.passwordFile ];

in {

  options.restic-backups = mkOption {
    type = with types; attrsOf (submodule backupOpts);
    default = { };
  };

  config = mkIf (backups != { }) {

    systemd.services = mapAttrs' (name: backup:
      nameValuePair "restic-backup-${name}" {
        restartIfChanged = false;
        requires = [ "network.target" "local-fs.target" ];
        onFailure = [ "email-notify@%i.service" ];
        startAt = backup.timerSpec;

        path = [ pkgs.restic ] ++ optionals (backup.postgresDatabases != [ ]) [
          config.services.postgresql.package
          pkgs.zstd
        ];

        serviceConfig = {
          Type = "oneshot";
          User = backup.user;
          RuntimeDirectory = "restic-backup-${name}";
          CacheDirectory = "restic-backup-${name}";
          CacheDirectoryMode = "0700";
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          Environment = [ "RESTIC_PASSWORD_FILE=${backup.passwordFile}" ];
          BindReadOnlyPaths = getPasswordFiles backup ++ backup.paths;
          ExecStartPre = optional (backup.postgresDatabases != [ ])
            (pkgs.writeScript "pre-start" (''
              #!${pkgs.runtimeShell}
              set -eu pipefail

            '' + concatMapStringsSep "\n" (db: ''
              echo "Dumping Postgres-database: ${db}"
              mkdir -p /tmp/postgresDatabases
              pg_dump ${db} | zstd --rsyncable > /tmp/postgresDatabases/${db}.sql.zst
              [ $(du -b /tmp/postgresDatabases/${db}.sql.zst | cut -f1) -gt "50" ] || exit 1
            '') backup.postgresDatabases));
        };

        script = ''
          set -eu pipefail
          export XDG_CACHE_HOME=/var/cache/restic-backup-${name}

        '' + concatMapStringsSep "\n\n" (server:
          let
            passwordCmd = lib.optionalString (server.passwordFile != null)
              "$(cat ${escapeShellArg server.passwordFile})";
            repoPath = if (server.repoPath == null) then
              "${config.networking.hostName}-${name}"
            else
              server.repoPath;
          in ''
            echo "Backing up to: ${server.protocol}://${server.hostname}"

            export RESTIC_REPOSITORY="${server.protocol}://${server.user}:${passwordCmd}@${server.hostname}/${repoPath}"

            #create repo if it not exists
            restic snapshots || restic init

            #backup files
            restic backup ${
              escapeShellArgs (backup.paths
                ++ optional (backup.postgresDatabases != [ ])
                "/tmp/postgresDatabases")
            }

            restic check
          '') backup.targets;

      }) backups;
  };

}
