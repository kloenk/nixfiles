{ config, lib, pkgs, ... }:

{
  systemd.services.fabric = {
    description = "Minecraft fabric server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "fabric.socket" ];
    serviceConfig = {
      BindPaths = "/persist/data/terra-indrev:/var/lib/private/fabric";
      ReadWritePaths = "/persist/data/terra-indrev";
      Restart = "always";
      DynamicUser = true;
      StateDirectory = "fabric";
      StandardInput = "socket";
      StandardOutput = "journal";
      WorkingDirectory="/var/lib/fabric";

      ExecStart = "${pkgs.jdk16_headless}/bin/java -Xms512M -Xmx4G -jar fabric-server-launch.jar --nogui";

      # Sandboxing
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
      RestrictRealtime = true;
      RestrictNamespaces = true;
      MemoryDenyWriteExecute = true;
    };
    /*script = ''
      ${pkgs.jdk16_headless}/bin/java -Xms512M -Xmx4G -jar fabric-server-launch.jar nogui
    '';*/
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
