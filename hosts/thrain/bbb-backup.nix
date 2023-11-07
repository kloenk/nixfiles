{ config, lib, pkgs, ... }:

let
  backupDir = { dir, unitname ? "bbb-backup-${targetDir}"
    , targetDir ? "${builtins.baseNameOf dir}" }: {
      systemd.services."${unitname}" = {
        after = [ "network.target" ];
        script = ''
          ${pkgs.rsync}/bin/rsync -a -e "${pkgs.openssh}/bin/ssh -o UserKnownHostsFile=/etc/bbb_hostkey -o IdentityFile=$CREDENTIALS_DIRECTORY/bbb_creds" \
            root@event.unterbachersee.de:${dir}/ /var/lib/bbb_backup/${targetDir}/
        '';

        serviceConfig = {
          LoadCredential = "bbb_creds:${config.sops.secrets."bbb".path}";
          StateDirectory = "bbb_backup/${targetDir}";
          BindPaths =
            "/persist/bbb_backupvideos/${targetDir}:/var/lib/bbb_backup/${targetDir}";
          ReadWritePaths = "/persist/bbb_backupvideos/${targetDir}";
          DynamicUser = false;
          User = "bbb_backup";
          Group = "bbb_backup";

          # sandboxing
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectControlGroups = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          RestrictAddressFamilies =
            [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
          RestrictRealtime = true;
          RestrictNamespaces = true;
          MemoryDenyWriteExecute = true;
        };
        unitConfig.RequiresMountsFor =
          [ "/persist/bbb_backupvideos/${targetDir}" ];
      };
      systemd.timers."${unitname}" = {
        wantedBy = [ "timers.target" ];
        partOf = [ "${unitname}.service" ];
        timerConfig.OnCalendar = "*-*-* 4:30:00";
      };
    };
in {
  sops.secrets."bbb".owner = "root";
  sops.secrets."nas".owner = "root";
  environment.etc."bbb_hostkey".text =
    "event.unterbachersee.de,46.4.108.116,2a01:4f8:141:4fc::2 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rHGk+z7rfTZAor8rh2n6DvzAKsssLe1P8CJcGvXFB";

  users.users.bbb_backup = {
    isSystemUser = true;
    createHome = false;
    group = "bbb_backup";
  };
  users.groups.bbb_backup = { };

  fileSystems."/persist/bbb_backupvideos" = {
    device = "//192.168.178.68/bbb_backupvideos";
    fsType = "cifs";
    options = [
      "credentials=${config.sops.secrets."nas".path}"
      "uid=bbb_backup"
      "gid=bbb_backup"
    ];
  };

} // backupDir {
  dir = "/var/bigbluebutton/published/presentation";
  targetDir = "published";
}
