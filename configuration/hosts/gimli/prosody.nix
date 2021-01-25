{ config, lib, pkgs, ... }:

let

in {
  petabyte.secrets."turncredentials-secret.lua".owner = "prosody";

  services.prosody = {
    extraConfig = ''
      turncredentials_host = "turn.kloenk.dev"
      Include "${config.petabyte.secrets."turncredentials-secret.lua".path}"
    '';
  };
}
