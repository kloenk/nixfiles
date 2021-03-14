{ config, lib, pkgs, ... }:

{
  petabyte.secrets."nas_creds".owner = "root";

  fileSystems."/persist/bbb_backupvideos" = {
    device = "//192.168.178.68/bbb_backupvideos";
    fsType = "cifs";
    options = [ "credentials=${config.petabyte.secrets."nas_creds".path}" ];
  };
}
