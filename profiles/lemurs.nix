{ lib, config, pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };

  sway = pkgs.writeShellScript "sway" ''
    exec ${config.home-manager.users.kloenk.home.path}/bin/sway
  '';

  lemursConfig = tomlFormat.generate "lemurs-config.toml" {
    background = {
      show_background = false;
      style = {
        border_color = "white";
        color = "black";
        show_border = true;
      };
    };
    cache_path = "/var/cache/lemurs";
    client_log_path = "/var/log/lemurs.client.log";
    do_log = true;
    environment_switcher = {
      include_tty_shell = true;
      left_mover = "<";
      max_display_length = 8;
      mover_color = "dark gray";
      mover_color_focused = "orange";
      mover_margin = 1;
      mover_modifiers = "";
      mover_modifiers_focused = "bold";
      neighbour_color = "dark gray";
      neighbour_color_focused = "gray";
      neighbour_margin = 1;
      neighbour_modifiers = "";
      neighbour_modifiers_focused = "";
      no_envs_color = "white";
      no_envs_color_focused = "red";
      no_envs_modifiers = "";
      no_envs_modifiers_focused = "";
      no_envs_text = "No environments...";
      remember = true;
      right_mover = ">";
      selected_color = "gray";
      selected_color_focused = "white";
      selected_modifiers = "underlined";
      selected_modifiers_focused = "bold";
      show_movers = true;
      show_neighbours = true;
      switcher_visibility = "visible";
      toggle_hint = "Switcher %key%";
      toggle_hint_color = "dark gray";
      toggle_hint_modifiers = "";
    };
    focus_behaviour = "default";
    main_log_path = "/var/log/lemurs.log";
    pam_service = "lemurs";
    password_field = {
      content_replacement_character = "*";
      style = {
        border_color = "white";
        border_color_focused = "orange";
        content_color = "white";
        content_color_focused = "orange";
        max_width = 48;
        show_border = true;
        show_title = true;
        title = "Password";
        title_color = "white";
        title_color_focused = "orange";
        use_max_width = true;
      };
    };
    power_controls = {
      base_entries = [
        {
          cmd = "${pkgs.systemd}/bin/systemctl poweroff -l";
          hint = "Shutdown";
          hint_color = "dark gray";
          hint_modifiers = "";
          key = "F1";
        }
        {
          cmd = "${pkgs.systemd}/bin/systemctl reboot -l";
          hint = "Reboot";
          hint_color = "dark gray";
          hint_modifiers = "";
          key = "F2";
        }
      ];
      entries = [{
        cmd =
          "${pkgs.efibootmgr}/bin/efibootmgr -n0000 && ${pkgs.systemd}/bin/systemctl reboot -l";
        hint = "Windows";
        hint_color = "dark gray";
        hint_modifiers = "";
        key = "F3";
      }];
      hint_margin = 2;
    };
    shell_login_flag = "short";
    system_shell = "/bin/sh";
    tty = 2;
    username_field = {
      remember = true;
      style = {
        border_color = "white";
        border_color_focused = "orange";
        content_color = "white";
        content_color_focused = "orange";
        max_width = 48;
        show_border = true;
        show_title = true;
        title = "Login";
        title_color = "white";
        title_color_focused = "orange";
        use_max_width = true;
      };
    };
    wayland = {
      scripts_path = pkgs.linkFarm "wayland" [{
        name = "sway";
        path = sway;
      }];
      wayland_sessions_path =
        "${config.home-manager.users.kloenk.home.path}/share/wayland-sessions";
    };
    x11 = {
      scripts_path = "/etc/lemurs/wms";
      x11_display = ":1";
      xauth_path = "/usr/bin/xauth";
      xserver_log_path = "/var/log/lemurs.xorg.log";
      xserver_path = "/usr/bin/X";
      xserver_timeout_secs = 60;
      xsessions_path = "/usr/share/xsessions";
      xsetup_path = "/etc/lemurs/xsetup.sh";
    };
  };
in {
  systemd.services.lemurs = {
    after = [
      "systemd-user-sessions.service"
      "plymouth-quit-wait.service"
      "getty@tty2.service"
    ];
    wantedBy = [ "getty.target" ];
    description = "lemurs login manager";
    aliases = [ "display-manager.service" ];
    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${pkgs.lemurs}/bin/lemurs -c ${lemursConfig}";
      StandardInput = "tty";
      TTYPath = "/dev/tty2";
      TTYReset = "yes";
      TTYVHangup = "yes";
      Type = "idle";
    };
  };

  security.pam.services.lemurs = {
    allowNullPassword = true;
    enableGnomeKeyring = true;
    setLoginUid = true;
    startSession = true;
    updateWtmp = true;
  };
}
