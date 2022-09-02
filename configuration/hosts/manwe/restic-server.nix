{ config, lib, ... }:


{
  networking.firewall.interfaces.usee0.allowedTCPPorts = [ 8080 ];
  networking.firewall.interfaces.wg00.allowedTCPPorts = [ 8080 ];

  services.restic.server = {
    enable = true;
    dataDir = "/persist/backups/restic-server";
    appendOnly = true;
    extraFlags = [ "--no-auth" ];
    prometheus = true;
    listenAddress = ":8080";
  };
}
