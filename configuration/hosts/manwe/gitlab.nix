{ config, pkgs, lib, ... }:

{
  fileSystems."/var/gitlab" = {
    device = "/persist/data/gitlab";
    options = [ "bind" ];
  };

  services.nginx.virtualHosts."lab.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
  };

  services.gitlab = {
    enable = true;

    smtp = {
      enable = true;
      username = "lab@kloenk.dev";
      passwordFile = config.petabyte.secrets."gitlab/mail".path;
      domain = "gimli.kloenk.dev";
      address = "gimli.kloenk.dev";
      port = 465;
      tls = true;
      enableStartTLSAuto = false;
    };

    host = "lab.kloenk.dev";
    port = 443;
    https = true;

    initialRootPasswordFile =
      config.petabyte.secrets."gitlab/initial-root-password".path;
    secrets = {
      secretFile = config.petabyte.secrets."gitlab/secret".path;
      otpFile = config.petabyte.secrets."gitlab/otp-secret".path;
      dbFile = config.petabyte.secrets."gitlab/db-secret".path;
      jwsFile = config.petabyte.secrets."gitlab/jws-secret".path;
    };

    extraConfig = {
      gitlab = {
        username_changing_enabled = false;
        email_from = "lab@kloenk.dev";
        email_display_name = "Kloenk GitLab";
        email_reply_to = "lab@kloenk.dev";
      };

      incoming_email = {
        enabled = true;
        mailbox = "inbox";
        address = "lab+%{key}@kloenk.dev";
        user = config.services.gitlab.smtp.username;
        password._secret = config.services.gitlab.smtp.passwordFile;
        host = "gimli.kloenk.dev";
        port = 993;
        ssl = true;
        start_tls = false;
        expunge_deleted = true;
      };
    };
  };

  # Unlike omnibus-based instances, a self-compiled gitlab does not automatically
  # rotate its logfiles.
  services.logrotate = {
    enable = true;
    paths = {
      gitlab = {
        path = config.services.gitlab.statePath + "/log/*.log";
        user = config.services.gitlab.user;
        group = config.services.gitlab.group;
        frequency = "daily";
        keep = 30;
        extraConfig = ''
          compress
          copytruncate
        '';
      };
    };
  };

  # bump worker memory limit to 1.5G
  systemd.services.gitlab.environment.GITLAB_UNICORN_MEMORY_MAX = "1500000000";

  petabyte.secrets."gitlab/initial-root-password".owner = "gitlab";
  petabyte.secrets."gitlab/otp-secret".owner = "gitlab";
  petabyte.secrets."gitlab/db-secret".owner = "gitlab";
  petabyte.secrets."gitlab/jws-secret".owner = "gitlab";
  petabyte.secrets."gitlab/secret".owner = "gitlab";
  petabyte.secrets."gitlab/mail".owner = "gitlab";
}
