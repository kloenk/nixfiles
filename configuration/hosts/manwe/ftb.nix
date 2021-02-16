{ config, lib, pkgs, ... }:

{
  /*fileSystems."/var/lib/ftb-server" = {
    device = "/persist/data/ftb";
    options = [ "bind" ];
  };*/

  systemd.services.ftb-server = {
    description = "Minecraft ftb server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "ftb-server.socket" ];
    serviceConfig = {
      BindPaths = "/persist/data/ftb:/var/lib/ftb-server";
      ReadWritePaths = "/persist/data/ftb";
      Restart = "always";
      DynamicUser = true;
      StateDirectory = "ftb-server";
      StandardInput = "socket";
      StandardOutput = "journal";
    };
    script = ''
      pwd
      cd /var/lib/ftb-server
      ls
      ${pkgs.jre8}/bin/java -Xms512M -Xmx4G -jar ftbserver.jar --nogui
    '';
  };
  systemd.sockets.ftb-server = {
    description = "Minecraft stdin fifo file";
    socketConfig = {
      ListenFIFO = "/run/minecraft/stdin";
      SocketMode = "0660";
    };
  };


  networking.firewall.allowedTCPPorts = [ 25565 ];
}
