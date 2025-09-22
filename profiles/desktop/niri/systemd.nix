{ lib, ... }:

{
  systemd.user = {
    slices = {
      session-niri = { sliceConfig = { CPUWeight = 100; }; };
      session-niri-service = {
        sliceConfig = {
          CPUWeight = 50;
          MemoryHigh = "1G";
          MemoryMax = "2G";
          SocketBindDeny = "any";
        };
      };
    };

    services = {
      niri = {
        overrideStrategy = "asDropin";
        serviceConfig.slice = "session-niri.slice";
        environment.PATH = lib.mkForce (lib.concatStringsSep ":" [
          "/run/wrappers/bin"
          "/home/kloenk/.nix-profile/bin"
          "/etc/profiles/per-user/kloenk/bin"
          "/nix/var/nix/profiles/default/bin"
          "/run/current-system/sw/bin"
        ]);
      };
      dunst = {
        overrideStrategy = "asDropin";
        serviceConfig = { slice = "session-niri-service.slice"; };
      };
      wpaperd = {
        overrideStrategy = "asDropin";
        serviceConfig = { slice = "session-niri-service.slice"; };
      };
      gammastep = {
        overrideStrategy = "asDropin";
        serviceConfig = { slice = "session-niri-service.slice"; };
      };

      # aaahh, go away!
      niri-flake-polkit.enable = false;
    };
  };
}
