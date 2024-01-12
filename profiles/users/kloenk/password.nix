{ config, ... }:

{
  users.users.kloenk.hashedPasswordFile =
    config.sops.secrets."passwords/kloenk".path;

  sops.secrets."passwords/kloenk" = {
    sopsFile = ../../../secrets/shared/passwords.yaml;
    neededForUsers = true;
    owner = "root";
  };
}
