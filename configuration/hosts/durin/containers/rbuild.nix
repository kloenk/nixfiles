{ lib, pkgs, config, ... }:

let
  ports = {
    ssh = 62957;
  };
in {
  fileSystems."/var/lib/machines/rbuild" = {
    device = "/persist/data/fedora-32";
    fsType = "none";
    options = [ "bind" ];
  };

  networking.firewall.allowedTCPPorts = [
    ports.ssh # ssh
  ];

  systemd.sockets.rbuild = {
    description = "SSH socket for durin-rbuild systemd container";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ (toString ports.ssh) ];
    socketConfig.Service = "systemd-nspawn@rbuild";
  };

  systemd.nspawn.rbuild = {
    networkConfig = {
      VirtualEthernet = "on";
      Bridge = [ "br0" ];
      Port = [ "62957" ];
    };
    filesConfig = {
      Bind = [
        #"/persist/data/rbuild/cache:/home/fin/cache"
        #"/persist/data/rbuild/out:/home/fin/packages"
        #"/persist/data/airlink/proj:/home/fin/airlink"
      ];
    };
    execConfig = {
      LinkJournal = "try-guest";
      NotifyReady = "yes";
      PrivateUsers = "yes";
      Boot = "yes";
    };
  };
}