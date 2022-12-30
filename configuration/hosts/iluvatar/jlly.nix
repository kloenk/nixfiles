{ config, ... }: {

  services.jlly_bot = {
    enable = true;
    config.":nostrum".":token"._secret =
      config.sops.secrets."jlly/bot/discord".path;
  };

  sops.secrets."jlly/bot/discord".owner = config.services.jlly_bot.user;
}
