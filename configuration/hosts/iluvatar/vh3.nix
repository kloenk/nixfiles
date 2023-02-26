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
    bindsTo = [ "minecraft-vh3.service" ];
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

    path = [ pkgs.bash pkgs.jdk17_headless ];

    serviceConfig = {
      ExecStart = "/persist/data/minecraft-vh3/start.sh";
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

  /*services.postgresql = {
    ensureUsers = [{
      name = "minecraft-vh3";
      ensurePermissions."DATABASE vh3" = "ALL PRIVILEGES";
    }];
    ensureDatabases = [ "vh3" ];
  };*/
}
