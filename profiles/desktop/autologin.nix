

{ lib, config, pkgs, ... }:

let tty = "tty1";
in {
  systemd.services."getty@${tty}" = {
    serviceConfig.ExecStart = [
      ""
      "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${config.services.getty.loginProgram} --skip-login --autologin kloenk --keep-baud %I 115200,38400,9600 $TERM"
    ];
    overrideStrategy = "asDropin";
    restartIfChanged = false;
  };

  home-manager.users.kloenk = {
    programs.zsh.initExtra = ''
      if [ -z "''${WAYLAND_DISPLAY}" ] && [[ "''${TTY}" == "/dev/${tty}" ]]; then
        systemctl --user import-environment PATH
        systemctl --user start sway.service swaylock.service
      fi
    '';
  };
}
