{ config, ... }: {

  services.p3tr = {
    enable = true;
    config.":nostrum".":token"._secret =
      config.sops.secrets."p3tr/bot/discord".path;
  };

  sops.secrets."p3tr/bot/discord".owner = config.services.p3tr.user;
}
