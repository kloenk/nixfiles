{ config, lib, ... }:


{
  networking.firewall.interfaces.usee0.allowedTCPPorts = [ 8080 ];

  services.restic.server = {
    enable = true;
    dataDir = "/persist/backups/restic-server";
    appendOnly = true;
    listenAddress = "192.168.56.1:8080";
  };
}
