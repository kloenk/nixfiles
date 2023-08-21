{ config, pkgs, lib, ... }:

let
  configAttr = {
    dialect = "uk";
    update_check = false;
    sync_address = "https://atuin.kloenk.eu";
    history_filter = [ "^sops" ];
    key_path = config.sops.secrets."atuin/key".path;
    session_path = config.sops.secrets."atuin/session".path;
  };
in {
  users.users.kloenk.packages = [ pkgs.atuin ];

  environment.variables.ATUIN_CONFIG_DIR = "/etc/atuin/";
  environment.etc."atuin/config.toml".source = let
    format = pkgs.formats.toml { };
    configFile = format.generate "config.toml" configAttr;
  in configFile;

  sops.secrets."atuin/key" = {
    sopsFile = ../../secrets/shared/atuin.yaml;
    owner = "kloenk";
    key = "key";
  };
  sops.secrets."atuin/session" = {
    sopsFile = ../../secrets/shared/atuin.yaml;
    owner = "kloenk";
    key = "session";
  };
}
