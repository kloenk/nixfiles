{ pkgs, ... }:

let
  hostname = "10.1.0.1";

  ipxeConfig = {
    client-classes = [
      {
        "name" = "XClient_iPXE";
        "test" = "substring(option[77].hex,0,4) == 'iPXE'";
        "boot-file-name" = "http://${hostname}/nixos.ipxe";
      }
      {
        "name" = "UEFI-32-1";
        "test" = "substring(option[60].hex,0,20) == 'PXEClient:Arch:00006'";
        "boot-file-name" = "ipxe.efi";
      }
      {
        "name" = "UEFI-32-2";
        "test" = "substring(option[60].hex,0,20) == 'PXEClient:Arch:00002'";
        "boot-file-name" = "ipxe.efi";
      }
      {
        "name" = "UEFI-64-1";
        "test" = "substring(option[60].hex,0,20) == 'PXEClient:Arch:00007'";
        "boot-file-name" = "ipxe.efi";
      }
      {
        "name" = "UEFI-64-2";
        "test" = "substring(option[60].hex,0,20) == 'PXEClient:Arch:00008'";
        "boot-file-name" = "ipxe.efi";
      }
      {
        "name" = "UEFI-64-3";
        "test" = "substring(option[60].hex,0,20) == 'PXEClient:Arch:00009'";
        "boot-file-name" = "ipxe.efi";
      }
      {
        "name" = "Legacy";
        "test" = "substring(option[60].hex,0,20) == 'PXEClient:Arch:00000'";
        "boot-file-name" = "undionly.kpxe";
      }
    ];
  };
in {
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
        inherit (ipxeConfig) client-classes;

        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = false;
          type = "memfile";
        };
        rebind-timer = 2000;
        renew-timer = 1000;
        valid-lifetime = 4000;

        interfaces-config.interfaces = [ "br-gwp" ];
        subnet4 = [{
          id = 1;
          pools = [{ pool = "10.1.0.50 - 10.1.0.150"; }];
          subnet = "10.1.0.0/24";

          option-data = [{
            name = "ntp-servers";
            data = "178.215.228.24";
          }];
        }];
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
}
