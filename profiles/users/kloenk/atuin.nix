{ config, ... }:

{
  home-manager.users.kloenk = {
    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        sync_address = "https://atuin.kloenk.eu/";
        key_path = config.sops.secrets."atuin/key".path;
      };
    };
  };

  sops.secrets."atuin/key" = {
    sopsFile = ../../../secrets/shared/atuin.yaml;
    owner = "kloenk";
  };
}
