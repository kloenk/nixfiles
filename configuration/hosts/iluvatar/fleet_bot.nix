{ config, ... }: {
  services.fleet_bot = {
    enable = true;
    config.":nostrum".":token"._secret = config.sops.secrets."fleet_bot/discord".path;
    config.":appsignal".":config" = {
      active = true;
      push_api_key._secret = config.sops.secrets."fleet_bot/appsignal".path;
    };
  };

  sops.secrets."fleet_bot/discord".owner = config.services.fleet_bot.user;
  sops.secrets."fleet_bot/appsignal".owner = config.services.fleet_bot.user;
}
