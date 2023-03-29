{ config, pkgs, ... }:

{
  services.akkoma = {
    enable = true;
    config = with (pkgs.formats.elixirConf { }).lib; {
      ":pleroma".":instance" = {
        name = "Kloenk's Akkoma";
        description = "Kloenk sometimes is also social";
        email = "akkoma@kloenk.dev";
        registration_open = false;
        invites_enabled = true;
        public = true;
        languages = [ "en" "de" ];
      };
      ":pleroma"."Pleroma.Web.Endpoint".url.host = "social.kloenk.eu";

      ":pleroma".":mrf".policies =
        map mkRaw [ "Pleroma.Web.ActivityPub.MRF.SimplePolicy" ];
      ":pleroma".":mrf_simple" = {
        # Tag all media as sensitive
        media_nsfw = mkMap { "nsfw.weird.kinky" = "Untagged NSFW content"; };

        # Reject all activities except deletes
        reject = mkMap {
          "kiwifarms.cc" = "Persistent harassment of users, no moderation";
          "freespeechextremist.com" = "Old list";
          "gleasonator.com" = "Old list";
          "gab.com" = "Old list";
          "gab.ai" = "Old list";
          "spinster.xyz" = "Old list";
          "shitposter.club" = "Old list";
          "neckbeard.xyz" = "Old list";
          "gitmo.life" = "Old list";
        };

        # Force posts to be visible by followers only
        followers_only = mkMap {
          "beta.birdsite.live" = "Avoid polluting timelines with Twitter posts";
        };
      };
      ":pleroma".":restrict_unauthenticated".timelines = {
        local = false;
        federated = true;
      };

      ":pleroma"."Pleroma.Upload".filters = map mkRaw [
        "Pleroma.Upload.Filter.Exiftool"
        "Pleroma.Upload.Filter.Dedupe"
        "Pleroma.Upload.Filter.AnonymizeFilename"
      ];
    };

    nginx = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
