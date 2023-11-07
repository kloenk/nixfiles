{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.boot.initrd;
in {
  config = mkIf cfg.network.ssh.enable {
    boot.initrd.network.ssh = {
      hostKeys = lib.mkDefault [ config.sops.secrets."initrd/ssh".path ];
    };
    sops.secrets."initrd/ssh".owner = "root";
  };
}
