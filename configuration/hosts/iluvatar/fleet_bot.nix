{ config, ... }: {
  services.fleet_bot = {
    enable = true;
    config.":fleet_bot"."FleetBot.Telemetry" = {
      enabled = true;
      auth.token._secret = config.sops.secrets."fleet_bot/influx".path;
      bucket = "fleetyards";
      org = "Fleetyards";
      host = "influx.kloenk.dev";
      scheme = "https";
      port = 443;
    };
    config.":nostrum".":token"._secret =
      config.sops.secrets."fleet_bot/discord".path;
    config.":appsignal".":config" = {
      active = true;
      push_api_key._secret = config.sops.secrets."fleet_bot/appsignal".path;
    };
  };

  sops.secrets."fleet_bot/discord".owner = config.services.fleet_bot.user;
  sops.secrets."fleet_bot/appsignal".owner = config.services.fleet_bot.user;
  sops.secrets."fleet_bot/influx".owner = config.services.fleet_bot.user;
}
