{ config, lib, pkgs, ... }:


let
  backupDir = { dir, unitname ? "bbb-backup-${targetDir}", targetDir ? "${builtins.baseNameOf dir}" }: {
    systemd.services."${unitname}" = {
      after = [ "network.target" ];
      script = ''
        ${pkgs.rsync}/bin/rsync -a -e "${pkgs.openssh}/bin/ssh -o UserKnownHostsFile=/etc/bbb_hostkey -o IdentityFile=$CREDENTIALS_DIRECTORY/bbb_creds" \
          root@stream.unterbachersee.de:${dir}/ /var/lib/bbb_backup/${targetDir}/
      '';

      serviceConfig = {
        LoadCredential = "bbb_creds:${config.petabyte.secrets."bbb_creds".path}";
        StateDirectory = "bbb_backup/${targetDir}";
        BindPaths = "/persist/bbb_backupvideos/${targetDir}:/var/lib/bbb_backup/${targetDir}";
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
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
        RestrictRealtime = true;
        RestrictNamespaces = true;
        MemoryDenyWriteExecute = true;
      };
    };
    systemd.timers."${unitname}" = {
      wantedBy = [ "timers.target" ];
      partOf = [ "${unitname}.service" ];
      timerConfig.OnCalendar = "*-*-* 4:30:00";
    };
  };
in
{
  petabyte.secrets."nas_creds".owner = "root";
  petabyte.secrets."bbb_creds".owner = "root";
  environment.etc."bbb_hostkey".text = "stream.unterbachersee.de,144.76.103.12,2a01:4f8:192:430b::2 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLqJOQVdy5FlBV77JPVHLMKd5hg1LGW4alDj52Aky3qj7hY95gwzFHnV8UoZqQmt+t4y2i/fT1vWdwDBfQY7zxM=";

  users.users.bbb_backup = {
    isSystemUser = true;
    createHome = false;
    group = "bbb_backup";
  };
  users.groups.bbb_backup = {};

  fileSystems."/persist/bbb_backupvideos" = {
    device = "//192.168.178.68/bbb_backupvideos";
    fsType = "cifs";
    options = [ "credentials=${config.petabyte.secrets."nas_creds".path}" "uid=bbb_backup" "gid=bbb_backup" ];
  };

} // backupDir { dir = "/var/bigbluebutton/published/presentation"; targetDir = "published"; }
