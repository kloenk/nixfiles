{ lib, pkgs, ... }:

let
  hostname = "10.1.0.1";

  gwpHostReservations = [{
    name = "edge-ng-0001";
    mac = "00:01:05:95:45:90";
  }];

  makeIp = i: "10.1.0.${toString (100 + i)}";

  gwpHostSubnetReservations = lib.imap0 (i: host: {
    hw-address = host.mac;
    ip-address = makeIp i;
    hostname = "${host.name}.gwp.internal";
  }) gwpHostReservations;

  gwpHostsConfigs = lib.imap0 (i: host: {
    networking.hosts.${makeIp i} = [ "${host.name}.gwp.internal" ];

    programs.ssh.extraConfig = ''
      Host ${host.name}.gwp
        Hostname ${host.name}.gwp.internal
        Port 22
        User root
        UserKnownHostsFile /dev/null
        StrictHostKeyChecking no
    '';
  }) gwpHostReservations;
in {
  config = lib.mkMerge ([{
    fileSystems."/var/lib/private/kea" = {
      device = "/persist/data/kea";
      fsType = "none";
      options = [ "bind" ];
    };

    networking.firewall.allowedUDPPorts = [ 69 ];

    services.kea = {
      dhcp4 = {
        enable = true;
        settings = {
          #inherit (ipxeConfig) client-classes;
          client-classes = [
            {
              "name" = "XClient_iPXE";
              "test" = "substring(option[77].hex,0,4) == 'iPXE'";
              "boot-file-name" = "http://${hostname}/nixos.ipxe";
            }
            {
              "name" = "UEFI-32-1";
              "test" =
                "substring(option[60].hex,0,20) == 'PXEClient:Arch:00006'";
              "boot-file-name" = "ipxe.efi";
            }
            {
              "name" = "UEFI-32-2";
              "test" =
                "substring(option[60].hex,0,20) == 'PXEClient:Arch:00002'";
              "boot-file-name" = "ipxe.efi";
            }
            {
              "name" = "UEFI-64-1";
              "test" =
                "substring(option[60].hex,0,20) == 'PXEClient:Arch:00007'";
              "boot-file-name" = "ipxe.efi";
            }
            {
              "name" = "UEFI-64-2";
              "test" =
                "substring(option[60].hex,0,20) == 'PXEClient:Arch:00008'";
              "boot-file-name" = "ipxe.efi";
            }
            {
              "name" = "UEFI-64-3";
              "test" =
                "substring(option[60].hex,0,20) == 'PXEClient:Arch:00009'";
              "boot-file-name" = "ipxe.efi";
            }
            {
              "name" = "Legacy";
              "test" =
                "substring(option[60].hex,0,20) == 'PXEClient:Arch:00000'";
              "boot-file-name" = "undionly.kpxe";
            }
          ];

          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = false;
            type = "memfile";
          };
          rebind-timer = 2000;
          renew-timer = 1000;
          valid-lifetime = 4000;

          interfaces-config.interfaces = [ "gwp-br0" "gwp-oob" ];
          subnet4 = [
            {
              id = 1;
              pools = [{ pool = "10.1.0.50 - 10.1.0.99"; }];
              interface = "gwp-br0";
              subnet = "10.1.0.0/24";

              reservations = gwpHostSubnetReservations;

              option-data = [{
                name = "ntp-servers";
                data = "178.215.228.24";
              }];
            }
            {
              id = 50;
              pools = [{ pool = "10.1.50.50 - 10.1.50.150"; }];
              interface = "gwp-oob";
              subnet = "10.1.50.0/24";

              option-data = [ ];
            }
          ];
        };
      };
    };

    services.nginx.virtualHosts."10.1.0.1" = {
      default = true;
      listenAddresses = [ "10.1.0.1" ];
      root = "/persist/data/secunet/public/";
      locations."/" = { extraConfig = "autoindex on;"; };
      locations."/upload".proxyPass = "http://localhost:12872/";
    };

    systemd.services.gwp-installer-upload-server = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        PrivateDevices = true;
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectHostname = true;
        LockPersonality = true;
        ProtectHome = true;
        PrivateUsers = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [ "AF_PACKET" "AF_INET" "AF_INET6" ];
        RuntimeDirectory = "uploads";

        User = "gwp-installer-upload-server";
        Group = "gwp-installer-upload-server";
        DynamicUser = true;
        ExecStart = "${pkgs.python3}/bin/python3 ${./gwp-server.py}";
      };
    };

    services.atftpd = {
      enable = true;
      extraOptions = [ "--bind-address 10.1.0.1" ];
      root = "${pkgs.ipxe.override {
        embedScript = pkgs.writeText "embed.ipxe" ''
          #!ipxe
          dhcp
          set gwp_install_server_url http://10.1.0.1/config/
          chain http://10.1.0.1/nixos.ipxe
        '';
      }}";
    };
  }] ++ gwpHostsConfigs);
}
