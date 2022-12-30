{ config, lib, pkgs, ... }:

{
  services.restic.backups.pbb = {
    #initialize = true;
    passwordFile = config.petabyte.secrets."restic-pbb".path;
    paths = [
      "/persist/data"
    ];
    repository = "rest:https://regolith.petabyte.dev/restic/kloenk";
  };

  petabyte.secrets."restic-pbb".owner = "root";
}
