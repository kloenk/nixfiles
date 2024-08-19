{ config, lib, pkgs, ... }:

{
  imports = [ ./dmarc-report.nix ./rspamd.nix ];

  fileSystems."/var/vmail" = {
    device = "/persist/data/vmail";
    options = [ "bind" ];
  };

  fileSystems."/var/dkim" = {
    device = "/persist/data/dkim";
    options = [ "bind" ];
  };

  networking.firewall.allowedTCPPorts = [
    143
    587
    25
    465
    993
    4190 # e
  ];

  services.postfix.config = {
    #relay_domains = [ "kloenk.de" ];
    mydestination = lib.mkOverride 25 [
      "$myhostname"
      "localhost"
    ]; # TODO: iluvatar.kloenk.dev?
    #maximal_queue_lifetime = "10d";
  };

  mailserver = {
    enable = true;
    localDnsResolver = false; # already running bind
    fqdn = "gimli.kloenk.de";
    domains = [
      "kloenk.de"
      "ad.kloenk.de"
      "drachensegler.kloenk.de"
      "drachensegler.kloenk.dev"
      "kloenk.dev"
      "p3tr1ch0rr.de"
      "sysbadge.dev"
    ];

    dmarcReporting = {
      enable = true;
      domain = "kloenk.de";
      fromName = "kloenk";
      localpart = "dmarc-noreply";
      organizationName = "kloenk";
    };

    rejectRecipients = [ "wattpad@kloenk.de" "kick@kloenk.de" ];

    loginAccounts = {
      "kloenk@kloenk.dev" = {
        hashedPasswordFile =
          config.sops.secrets."mail/kloenk_kloenk.de.sha512".path;

        aliases = [
          "kloenk@kloenk.de"
          "admin@kloenk.de"

          "postmaster@kloenk.de"
          "hostmaster@kloenk.de"
          "webmaster@kloenk.de"
          "abuse@kloenk.de"
          "postmaster@ad.kloenk.de"
          "hostmaster@ad.kloenk.de"
          "webmaster@ad.kloenk.de"
          "abuse@ad.kloenk.de"
          "postmaster@drachensegler.kloenk.de"
          "hostmaster@drachensegler.kloenk.de"
          "webmaster@drachensegler.kloenk.de"
          "abuse@drachensegler.kloenk.de"
          "postmaster@drachensegler.kloenk.dev"
          "hostmaster@drachensegler.kloenk.dev"
          "webmaster@drachensegler.kloenk.dev"
          "abuse@drachensegler.kloenk.dev"
          "postmaster@sysbadge.dev"
          "hostmaster@sysbadge.dev"
          "webmaster@sysbadge.dev"
          "abuse@sysbadge.dev"
          "delta@kloenk.de"
          "mail@kloenk.de"

          "mail@kloenk.dev"
          "admin@kloenk.dev"
          "postmaster@kloenk.dev"
          "hostmaster@kloenk.dev"
          "webmaster@kloenk.dev"
          "abuse@kloenk.dev"
          "postmaster@ad.kloenk.dev"
          "hostmaster@ad.kloenk.dev"
          "webmaster@ad.kloenk.dev"
          "abuse@ad.kloenk.dev"

          "mail@p3tr1ch0rr.de"
          "admin@p3tr1ch0rr.de"
          "postmaster@p3tr1ch0rr.de"
          "hostmaster@p3tr1ch0rr.de"
          "webmaster@p3tr1ch0rr.de"
          "abuse@p3tr1ch0rr.de"
        ];
      };

      "finn@kloenk.dev" = {
        hashedPasswordFile =
          config.sops.secrets."mail/finn_kloenk.de.sha512".path;

        aliases = [
          "finn.behrens@kloenk.de"
          "behrens.finn@kloenk.de"
          "info@kloenk.de"
          "me@kloenk.de"
          "finn@kloenk.de"
          "applications@kloenk.de"
          "applications@kloenk.dev"

          "finn.behrens@kloenk.dev"
          "behrens.finn@kloenk.dev"
          "info@kloenk.dev"
          "me@kloenk.dev"

          "info@sysbadge.dev"
        ];
      };

      "chaos@kloenk.de" = {
        hashedPasswordFile =
          config.sops.secrets."mail/chaos_kloenk.de.sha512".path;

        aliases =
          [ "35c3@kloenk.de" "eventphone@kloenk.de" "cryptoparty@kloenk.de" ];
      };

      "grafana@kloenk.dev" = {
        hashedPasswordFile =
          config.sops.secrets."mail/grafana_kloenk.de.sha512".path;

        aliases = [ "grafana@kloenk.de" ];
      };

      "dmarc@kloenk.dev" = {
        hashedPasswordFile = config.sops.secrets."mail/dmarc".path;

        aliases = [ "dmarc@kloenk.de" ];
      };

      "no-reply@kloenk.dev" = {
        hashedPasswordFile = config.sops.secrets."mail/no-reply".path;

        aliases = [ "no-reply@kloenk.de" "alertmanager@kloenk.de" ];
        sendOnly = true;
      };

      # youtrack todo mail
      "todo@kloenk.dev" = {
        hashedPasswordFile = config.sops.secrets."mail/todo".path;

        aliases = [ "todo@kloenk.de" "nixfiles@kloenk.dev" ];
      };

      "alertmanager@kloenk.de" = {
        hashedPasswordFile =
          config.sops.secrets."mail/alert_kloenk.de.sha512".path;

        aliases = [ "alertmanager@kloenk.dev" ];
      };

      "ad@kloenk.dev" = {
        hashedPasswordFile =
          config.sops.secrets."mail/ad_kloenk.de.sha512".path;

        aliases = [
          "ad@kloenk.de"
          "llgcompanion@kloenk.de"
          "telegram@kloenk.de"
          "fff@kloenk.de"
          "punkte@kloenk.de"
          "lkml@kloenk.de"
          "n26@kloenk.de"
          "gerry70@kloenk.dev"
          "discord@kloenk.de"
          "con42@kloenk.dev"
          "cccv@kloenk.de"
          "bahn@ad.kloenk.de"
          "jlcpcb@kloenk.de"
        ];

        catchAll = [ "kloenk.dev" "kloenk.de" "ad.kloenk.de" ];
      };

      "drachensegler@drachensegler.kloenk.de" = {
        hashedPasswordFile =
          config.sops.secrets."mail/drachensegler_drachensegler.kloenk.de.sha512".path;

        aliases = [
          "drachensegler@kloenk.de"
          "dlrg@drachensegler.kloenk.de"
          "dlrg.jugend@drachensegler.kloenk.de"
          "dlrg.jugend@drachensegler.kloenk.dev"
          "tjaard@drachensegler.kloenk.de"
          "tjaard@kloenk.de"
          "schule@drachensegler.kloenk.de"
          "iandmi@drachensegler.kloenk.de"
          "iandme@drachensegler.kloenk.de"
          "autodesk@drachensegler.kloenk.de"
        ];

        catchAll = [ "drachensegler.kloenk.dev" "drachensegler.kloenk.de" ];
      };

      "git@kloenk.de" = {
        hashedPasswordFile =
          config.sops.secrets."mail/git_kloenk.de.sha512".path;
      };

      "me@p3tr1ch0rr.de" = {
        hashedPasswordFile =
          config.sops.secrets."mail/me_p3tr1ch0rr.de.bcypt".path;

        aliases = [
          "tobi@p3tr1ch0rr.de"
          "p3tr1ch0rr@p3tr1ch0rr.de"
          "p3tr@p3tr1ch0rr.de"
        ];
        catchAll = [ "p3tr1ch0rr.de" ];
      };

    };

    extraVirtualAliases = {
      #"schluempfli@kloenk.de" = "holger@trudeltiere.de";
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";

    enableImap = true;
    enablePop3 = false;
    enableImapSsl = true;
    enablePop3Ssl = false;

    # Enable the ManageSieve protocol
    enableManageSieve = true;

    # whether to scan inbound emails for viruses (note that this requires at least
    # 1 Gb RAM for the server. Without virus scanning 256 MB RAM should be plenty)
    virusScanning = false;
  };

  sops.secrets = {
    "mail/kloenk_kloenk.de.sha512".owner = "root";
    "mail/finn_kloenk.de.sha512".owner = "root";
    "mail/chaos_kloenk.de.sha512".owner = "root";
    "mail/grafana_kloenk.de.sha512".owner = "root";
    "mail/eljoy_kloenk.de.sha512".owner = "root";
    "mail/alert_kloenk.de.sha512".owner = "root";
    "mail/ad_kloenk.de.sha512".owner = "root";
    "mail/git_kloenk.de.sha512".owner = "root";
    "mail/drachensegler_drachensegler.kloenk.de.sha512".owner = "root";
    "mail/me_p3tr1ch0rr.de.bcypt".owner = "root";
    "mail/no-reply".owner = "root";
    "mail/todo".owner = "root";
    "mail/dmarc".owner = "root";
  };

  # sieve mailing ordering
  services.dovecot2 = {
    extraConfig = ''
      protocol sieve {
        managesieve_logout_format = bytes ( in=%i : out=%o )
      }
      plugin {
        sieve_dir = /var/vmail/%d/%n/sieve/scripts/
        sieve = /var/vmail/%d/%n/sieve/active-script.sieve
        sieve_extensions = +vacation-seconds
        sieve_vacation_min_period = 1min
        fts = lucene
        fts_lucene = whitespace_chars=@.
      }
      # If you have Dovecot v2.2.8+ you may get a significant performance improvement with fetch-headers:
      imapc_features = $imapc_features fetch-headers
      # Read multiple mails in parallel, improves performance
      mail_prefetch_count = 20

      service imap {
        vsz_limit = 1024MB
      }
    '';
    modules = [ pkgs.dovecot_pigeonhole ];
    protocols = [ "sieve" ];
  };

  # itsbroken
  systemd.services.dovecot2.after = lib.mkForce [ "network.target" ];
  systemd.services.postfix.after = lib.mkForce [
    "network.target"
    "dovecot2.service"
    "opendkim.service"
    "rspamd.service"
  ];

  backups.mail = {
    user = "virtualMail";
    paths = [ "/persist/data/vmail" ];
  };
}
