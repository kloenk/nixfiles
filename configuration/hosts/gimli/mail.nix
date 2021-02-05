{ config, lib, pkgs, ... }:

{
  fileSystems."/var/vmail" = {
    device = "/persist/data/vmail";
    options = [ "bind" ];
  };

  fileSystems."/var/dkim" = {
    device = "/persist/secrets/dkim";
    options = [ "bind" ];
  };

  networking.firewall.allowedTCPPorts = [
    143
    587
    25
    465
    993
    4190 # sieve
  ];

  services.postfix.config = {
    #relay_domains = [ "kloenk.de" ];
    mydestination =
      lib.mkOverride 25 [ "$myhostname" "localhost" ]; # TODO: iluvatar.kloenk.dev?
    #maximal_queue_lifetime = "10d";
  };

  mailserver = {
    enable = true;
    localDnsResolver = false; # already running bind
    fqdn = "gimli.kloenk.dev";
    domains = [
      "kloenk.de"
      "ad.kloenk.de"
      "drachensegler.kloenk.de"
      "burscheider-imkerverein.de"
      "kloenk.dev"
    ];

    loginAccounts = {
      "kloenk@kloenk.dev" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/kloenk_kloenk.de.sha512".path;

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
          "postmaster@burscheider-imkerverein.de"
          "hostmaster@burscheider-imkerverein.de"
          "webmaster@burscheider-imkerverein.de"
          "abuse@burscheider-imkerverein.de"
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
        ];
      };

      "finn@kloenk.dev" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/finn_kloenk.de.sha512".path;

        aliases = [
          "finn.behrens@kloenk.de"
          "behrens.finn@kloenk.de"
          "info@kloenk.de"
          "me@kloenk.de"
          "finn@kloenk.de"

          "finn.behrens@kloenk.dev"
          "behrens.finn@kloenk.dev"
          "info@kloenk.dev"
          "me@kloenk.dev"
        ];
      };

      "praesidium@kloenk.de" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/praesidium_kloenk.de.sha512".path;

        aliases = [ "präsidium@kloenk.de" ];
      };

      "chaos@kloenk.de" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/chaos_kloenk.de.sha512".path;

        aliases =
          [ "35c3@kloenk.de" "eventphone@kloenk.de" "cryptoparty@kloenk.de" ];
      };

      "schule@kloenk.dev" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/schule_kloenk.de.sha512".path;
        aliases = [ "moodle+llg@kloenk.de" "sv@kloenk.de" "schule@kloenk.de" ];
      };

      "yougen@kloenk.dev" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/yougen_kloenk.de.sha512".path;

        aliases = [ "yougen@kloenk.de" ];
      };

      "grafana@kloenk.dev" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/grafana_kloenk.de.sha512".path;

        aliases = [ "grafana@kloenk.de" ];
      };

      "eljoy@kloenk.de" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/eljoy_kloenk.de.sha512".path;
        aliases = [ "eljoy2@kloenk.de" ];
      };

      "noreply-punkte@kloenk.de" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/nrpunkte_kloenk.de.sha512".path;
      };

      "alertmanager@kloenk.de" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/alert_kloenk.de.sha512".path;

        aliases = [ "alertmanager@kloenk.dev" ];
      };

      "ad@kloenk.dev" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/ad_kloenk.de.sha512".path;

        aliases = [
          "ad@kloenk.de"
          "llgcompanion@kloenk.de"
          "telegram@kloenk.de"
          "fff@kloenk.de"
          "punkte@kloenk.de"
          "lkml@kloenk.de"
          "n26@kloenk.de"
          "gerry70@kloenk.dev"
        ];

        catchAll = [ "kloenk.dev" "kloenk.de" "ad.kloenk.de" ];
      };

      "drachensegler@drachensegler.kloenk.de" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/drachensegler_drachensegler.kloenk.de.sha512".path;

        aliases = [
          "drachensegler@kloenk.de"
          "dlrg@drachensegler.kloenk.de"
          "tjaard@drachensegler.kloenk.de"
          "tjaard@kloenk.de"
          "schule@drachensegler.kloenk.de"
          "iandmi@drachensegler.kloenk.de"
          "iandme@drachensegler.kloenk.de"
          "autodesk@drachensegler.kloenk.de"
        ];

        catchAll = [ "drachensegler.kloenk.de" ];
      };

      "git@kloenk.de" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/git_kloenk.de.sha512".path;
      };

      # burscheider-imkerverein
      "tjaard@burscheider-imkerverein.de" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/drachensegler_drachensegler.kloenk.de.sha512".path;
      };

      "info@burscheider-imkerverein.de" = {
        hashedPasswordFile =
          config.petabyte.secrets."mail/info_burscheider-imkerverein.de.sha512".path;

        catchAll = [ "burscheider-imkerverein.de" ];
      };

    };

    extraVirtualAliases = {
      #"schluempfli@kloenk.de" = "holger@trudeltiere.de";
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = 3;

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

  petabyte.secrets = {
    "mail/kloenk_kloenk.de.sha512".owner = "root";
    "mail/finn_kloenk.de.sha512".owner = "root";
    "mail/praesidium_kloenk.de.sha512".owner = "root";
    "mail/chaos_kloenk.de.sha512".owner = "root";
    "mail/schule_kloenk.de.sha512".owner = "root";
    "mail/yougen_kloenk.de.sha512".owner = "root";
    "mail/grafana_kloenk.de.sha512".owner = "root";
    "mail/eljoy_kloenk.de.sha512".owner = "root";
    "mail/nrpunkte_kloenk.de.sha512".owner = "root";
    "mail/alert_kloenk.de.sha512".owner = "root";
    "mail/ad_kloenk.de.sha512".owner = "root";
    "mail/git_kloenk.de.sha512".owner = "root";
    "mail/drachensegler_drachensegler.kloenk.de.sha512".owner = "root";
    "mail/info_burscheider-imkerverein.de.sha512".owner = "root";
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
    '';
    modules = [ pkgs.dovecot_pigeonhole ];
    protocols = [ "sieve" ];
  };
}
