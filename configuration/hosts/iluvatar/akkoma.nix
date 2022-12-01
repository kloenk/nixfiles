{ config, lib, pkgs, ... }:

let

in {
  fileSystems."/var/lib/pleroma" = {
    device = "/persist/data/akkoma";
    fsType = "none";
    options = [ "bind" ];
  };

  services.akkoma = {
    enable = true;
    config = {
      ":pleroma" = {
        ":instance" = {
          name = "SocialKloenk";
          email = "social@kloenk.dev";
          limit = 5000;
          registrations_open = false;
          healthcheck = true;
        };
        "Pleroma.Web.Endpoint" = {
          url.host = "social.kloenk.dev";
          cache_static_manifest = "priv/static/cache_manifest.json";
        };
        "Pleroma.Captcha".enabled = false;
        ":database".rum_enabled = false;
        
        ":mrf".policies = [ "Pleroma.Web.ActivityPub.MRF.SimplePolicy" ];
        ":mrf_simple".reject = [
          "freespeechextremist.com"
          "gleasonator.com"
          "gab.com"
          "gab.ai"
          "spinster.xyz"
          "shitposter.club"
          "neckbeard.xyz"
          "gitmo.life"
        ];
        "Pleroma.Upload".filters = map (pkgs.formats.elixirConf { }).lib.mkRaw [
          "Pleroma.Upload.Filter.Exiftool"
          "Pleroma.Upload.Filter.Dedupe"
          "Pleroma.Upload.Filter.AnonymizeFilename"
        ];

        ":restrict_unauthenticated".timelines = { local = false; federated = true; };

        ":media_proxy" = {
          enabled = true;
          proxy_opts.redirect_on_failure = true;
        };
      };
    };
    nginx = {
      enableACME = true;
      forceSSL = true;

      locations."/proxy" = {
        proxyPass = "http://unix:/run/akkoma/socket";

        extraConfig = ''
          proxy_cache akkoma_media_cache;

          # Cache objects in slices of 1 MiB
          slice 1m;
          proxy_cache_key $host$uri$is_args$args$slice_range;
          proxy_set_header Range $slice_range;

          # Decouple proxy and upstream responses
          proxy_buffering on;
          proxy_cache_lock on;
          proxy_ignore_client_abort on;

          # Default cache times for various responses
          proxy_cache_valid 200 1y;
          proxy_cache_valid 206 301 304 1h;

          # Allow serving of stale items
          proxy_cache_use_stale error timeout invalid_header updating;
        '';
      };
    };
  };

  services.nginx.commonHttpConfig = ''
    proxy_cache_path /var/cache/nginx/cache/akkoma-media-cache
      levels= keys_zone=akkoma_media_cache:16m max_size=16g
      inactive=1y use_temp_path=off;
  '';


}