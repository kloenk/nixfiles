{ config, pkgs, ... }:

let
  stopScript = pkgs.writeShellScript "minecraft-server-stop" ''
    echo stop > ${config.systemd.sockets.minecraft-vh3.socketConfig.ListenFIFO}

    # Wait for the PID of the minecraft server to disappear before
    # returning, so systemd doesn't attempt to SIGKILL it.
    while kill -0 "$1" 2> /dev/null; do
      sleep 1s
    done
  '';
in {
  users.users.minecraft-vh3 = {
    isSystemUser = true;
    home = "/persist/data/minecraft-vh3";
    useDefaultShell = true;
    group = "minecraft";
  };

  users.groups.minecraft = { };

  systemd.sockets.minecraft-vh3 = {
    bindsTo = [ "minecraft-server.service" ];
    socketConfig = {
      ListenFIFO = "/run/minecraft-vh3-server.stdin";
      SocketMode = "0660";
      SocketUser = "minecraft-vh3";
      SocketGroup = "minecraft";
      RemoveOnStop = true;
      FlushPending = true;
    };
  };

  systemd.services.minecraft-vh3 = {
    description = "Minecraft VH3 server";
    wantedBy = [ "multi-user.target" ];
    requires = [ "minecraft-vh3.socket" ];
    after = [ "network.target" "minecraft-server.socket" "postgresql.service" ];

    serviceConfig = {
      ExecStart = "./start.sh";
      ExecStop = "${stopScript} $MAINPID";
      Restart = "always";
      User = "minecraft-vh3";
      WorkingDirectory = "/persist/data/minecraft-vh3";

      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";

      # Hardening
      CapabilityBoundingSet = [ "" ];
      DeviceAllow = [ "" ];
      LockPersonality = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };

  services.postgresql = {
    ensureUsers = [{
      name = "minecraft-vh3";
      ensurePermissions."DATABASE vh3" = "ALL PRIVILEGES";
    }];
    ensureDatabases = [ "vh3" ];
  };
}

/* { config, lib, pkgs, ... }:

   {
     systemd.services.fabric = {
       description = "Minecraft fabric server";
       wantedBy = [ "multi-user.target" ];
       after = [ "network.target" ];
       requires = [ "fabric.socket" ];
       serviceConfig = {
         BindPaths = "/persist/data/aof4:/var/lib/private/fabric";
         ReadWritePaths = "/persist/data/aof4";
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
       };
       script = ''
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
*/
