{ lib, config, pkgs, ... }:

let hm-user = config.home-manager.users.kloenk;
in {
  home-manager.users.kloenk = {
    systemd.user.services = {
      sway = {
        Unit = {
          After = [ "graphical-session-pre.target" ];
          Wants = [ "graphical-session-pre.target" ];
        };
        Service = {
          ExecStart =
            [ "${hm-user.wayland.windowManager.sway.package}/bin/sway" ];
          KillMode = "mixed";
        };
      };
      swaylock = {
        Unit = {
          Requisite = [ "sway.service" ];
          After = [ "sway.service" "sway-session.target" ];
        };
        Service = {
          ExecStart = [ "${hm-user.programs.swaylock.package}/bin/swaylock" ];
          KillSignal = "SIGUSR1";
        };
      };
    };
  };
}
