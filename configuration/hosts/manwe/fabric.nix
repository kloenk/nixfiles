{ config, lib, pkgs, ... }:

{
  systemd.services.fabric = {
    description = "Minecraft ftb server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "fabric.socket" ];
    serviceConfig = {
      BindPaths = "/persist/data/terra-indrev:/var/lib/terra-indrev";
      ReadWritePaths = "/persist/data/terra-indrev";
      Restart = "always";
      DynamicUser = true;
      StateDirectory = "terra-indrev";
      StandardInput = "socket";
      StandardOutput = "journal";
    };
    script = ''
      pwd
      cd /var/lib/terra-indrev
      ls
      ${pkgs.jdk16_headless}/bin/java -Xms512M -Xmx4G -jar fabric-server-launch.jar nogui
    '';
  };
  systemd.sockets.fabric = {
    description = "Minecraft stdin fifo file";
    socketConfig = {
      ListenFIFO = "/run/minecraft/stdin";
      SocketMode = "0660";
    };
  };


  networking.firewall.allowedTCPPorts = [ 25565 ];
}
