{ lib, ... }: {
  programs.firefox = {
    enable = true;
    languagePacks = [ "en-GB" "de" ];

    policies = {
      Certificates = { Install = [ ]; };
      DisableTelemetry = true;
      ExtensionSettings = lib.mapAttrs (id: shortName: {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/${shortName}/latest.xpi";
      }) {
        "FirefoxColor@mozilla.com" = "firefox-color";
        "@testpilot-containers" = "multi-account-containers";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
        "uBlock0@raymondhill.net" = "ublock-origin";
        # "momentum@momentumdash.com" = "momentumdash";
        "{f7f203e0-9d1d-4557-891f-9865877c5b48}" = "tabby-cat-friend";
      };
      PasswordManagerEnabled = false;
      UserMessaging = {
        WhatsNew = true;
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = true;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        Locked = true;
      };
    };
  };
}

