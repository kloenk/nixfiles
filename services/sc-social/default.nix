{ pkgs, config, lib, ... }:

let mastoConfig = config.services.mastodon;
in {
  fileSystems."/var/lib/elasticsearch" = {
    device = "/persist/data/elasticsearch";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/var/lib/redis-mastodon" = {
    device = "/persist/data/redis-mastodon";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/var/lib/mastodon" = {
    device = "/persist/data/mastodon";
    fsType = "none";
    options = [ "bind" ];
  };

  sops.secrets = let mastodon.owner = mastoConfig.user;
  in {
    "mastodon/smtp_password" = mastodon;
    "mastodon/otp_secret" = mastodon;
    "mastodon/secret_key" = mastodon;
    "mastodon/vapid/private_key" = mastodon;
    "mastodon/vapid/public_key" = mastodon;
    "restic/env" = mastodon;
    "restic/repo" = mastodon;
    #"restic-repo-password" = mastodon;
    #"restic-server-jules" = mastodon;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "elasticsearch" ];

  services.mastodon = let secrets = config.sops.secrets;
  in {
    enable = true;
    localDomain = "starcitizen.social";
    configureNginx = true;
    automaticMigrations = true;

    streamingProcesses = 3;

    secretKeyBaseFile = secrets."mastodon/secret_key".path;
    vapidPrivateKeyFile = secrets."mastodon/vapid/private_key".path;
    vapidPublicKeyFile = secrets."mastodon/vapid/public_key".path;
    otpSecretFile = secrets."mastodon/otp_secret".path;

    mediaAutoRemove = {
      enable = true;
      olderThanDays = 21;
    };

    elasticsearch = {
      port = config.services.elasticsearch.port;
      host = "127.0.0.1";
    };

    smtp = {
      createLocally = false;
      port = 465;
      host = "smtp.eu.mailgun.org";
      user = "postmaster@starcitizen.social";
      fromAddress = "info@starcitizen.social";
      authenticate = true;
      passwordFile = secrets."mastodon/smtp_password".path;
    };

    extraConfig = {
      MAX_TOOT_CHARS = "5000";
      MIN_POLL_OPTIONS = "1";
      MAX_POLL_OPTIONS = "10";
      MAX_DISPLAY_NAME_CHARS = "100";
      MAX_BIO_CHARS = "1000";
      MAX_PROFILE_FIELDS = "10";

      SMTP_ENABLE_STARTTLS_AUTO = "false";
      SMTP_ENABLE_STARTTLS = "never";
      SMTP_TLS = "true";

      # Reduce absolute spam of (every request^1) mastodon and sidekiq logs
      # ^1: https://docs.joinmastodon.org/admin/config/#rails_log_level
      RAILS_LOG_LEVEL = "warn";
    };
  };

  services.elasticsearch = {
    enable = true;
    package = pkgs.elasticsearch7;
    extraJavaOptions = [ "-Xms750m" "-Xmx750m" ];
    # Do not spam journalctl with "Elasticsearch built-in security features are not enabled." logs on search deploy
    # https://stackoverflow.com/a/68050804
    extraConf = ''
      xpack.security.enabled: false
    '';
  };

  systemd.services."mastodon-search-deploy" = {
    environment = lib.mkForce config.systemd.services.mastodon-web.environment;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "elasticsearch.service" "postgresql.service" ];
    requires = [ "elasticsearch.service" "postgresql.service" ];
    script = ''
      ${mastoConfig.package}/bin/tootctl search deploy
    '';
    serviceConfig = {
      Type = "simple";
      RemainAfterExit = true;

      WorkingDirectory = mastoConfig.package;
      User = mastoConfig.user;
      Group = mastoConfig.group;

      # Comming from
      # https://github.com/NixOS/nixpkgs/blob/nixos-22.05/nixos/modules/services/web-apps/mastodon.nix#L45-L86

      # State directory and mode
      StateDirectory = "mastodon";
      StateDirectoryMode = "0750";
      # Logs directory and mode
      LogsDirectory = "mastodon";
      LogsDirectoryMode = "0750";

      EnvironmentFile = "/var/lib/mastodon/.secrets_env";
    };
  };

  systemd.services.redis-mastodon.serviceConfig = {
    UMask = lib.mkForce "0027"; # 0077 is default in the mastodon module
    StateDirectoryMode =
      lib.mkForce "0750"; # 0700 is default in the mastodon module
  };

  restic-backups.mastodon = {
    user = mastoConfig.user;
    passwordFile = config.sops.secrets."restic/repo".path;
    postgresDatabases = [ mastoConfig.database.name ];
    paths = [
      "/var/lib/mastodon/public-system/media_attachments" # Hardcoded in the NixOS module
      "/var/lib/mastodon/public-system/site_uploads" # Hardcoded in the NixOS module
      "/var/lib/mastodon/public-system/accounts" # Hardcoded in the NixOS module
      (config.services.redis.servers.mastodon.settings.dir
        + "/dump.rdb") # Mastodon advised: https://docs.joinmastodon.org/admin/backups/#redis
    ];
    targets = [{
      user = "foo";
      passwordFile = "/dev/null";
      hostname = "fra1.digitaloceanspaces.com";
      protocol = "s3:https";
      repoPath = "starcitizen-social-bucket";
    }];
    timerSpec = "*-*-* 05:11:00";
  };

  systemd.services.restic-backup-mastodon.serviceConfig.EnvironmentFile =
    [ config.sops.secrets."restic/env".path ];

  systemd.services.restic-backup-mastodon.serviceConfig.SupplementaryGroups =
    config.systemd.services.redis-mastodon.serviceConfig.Group;
}
