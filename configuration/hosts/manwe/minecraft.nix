{ config, lib, pkgs, ... }:

{
  fileSystems."/var/lib/minecraft" = {
    device = "/persist/data/minecraft";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.services.minecraft = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.jdk17_headless}/bin/java -Dlog4j2.formatMsgNoLookups=true -jar fabric-server-launch.jar nogui";
      RuntimeDirectory = "minecraft";
      RootDirectory = "/run/minecraft";
      StateDirectory = "minecraft";
      WorkingDirectory = "/var/lib/minecraft";
      BindPaths = "/persist/data/minecraft:/var/lib/minecraft";
      ReadWritePaths = "/persist/data/minecraft";
      DynamicUser = true;
      BindReadOnlyPaths = [
        "/nix/store"
      ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 25565 ];
}
