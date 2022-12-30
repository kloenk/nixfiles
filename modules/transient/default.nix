{ lib, config, pkgs, ... }:

let
  cfg = config.kloenk.transient;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.kloenk.transient = {
    enable = mkEnableOption "Delete root on boot";

    vgroup = mkOption {
      type = types.str;
      default = config.networking.hostName;
    };

    partition = mkOption {
      type = types.str;
      default = "root";
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      ${pkgs.xfsprogs}/bin/mkfs.xfs -m reflink=1 -f /dev/${cfg.vgroup}/${cfg.partition}
    '';

    fileSystems = {
      "/var/lib/acme" = {
        device = "/persist/data/acme";
        fsType = "none";
        options = [ "bind" ];
      };
      "/root/.gnupg" = {
        device = "/persist/data/gnupg-root";
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };
      "/persist" = { neededForBoot = true; };
      "/".device = lib.mkForce "/dev/${cfg.vgroup}/${cfg.partition}";
    };

    systemd.services = with lib;
      listToAttrs (flatten (map (name: [
        # fix acme serviceConfig
        (nameValuePair "acme-${name}" {
          serviceConfig.ReadWritePaths = [ "/persist/data/acme" ];
          serviceConfig.BindPaths =
            mkBefore [ "/persist/data/acme:/var/lib/acme" ];
        })
        (nameValuePair "acme-selfsigned-${name}" {
          serviceConfig.ReadWritePaths = [ "/persist/data/acme" ];
          serviceConfig.BindPaths =
            mkBefore [ "/persist/data/acme:/var/lib/acme" ];
        })
        (nameValuePair "acme-finished-${name}" {
          serviceConfig.ReadWritePaths = [ "/persist/data/acme" ];
          serviceConfig.BindPaths =
            mkBefore [ "/persist/data/acme:/var/lib/acme" ];
        })
      ]) (attrNames config.security.acme.certs))) // {
        #"acme-fixperms" = {
        #   serviceConfig.ReadWritePaths = [ "/persist/data/acme" ];
        #   serviceConfig.BindPaths = mkBefore [
        #     "/persist/data/acme:/var/lib/acme"
        #   ];
        # };
        "acme-selfsigned-ca" = {
          serviceConfig.ReadWritePaths = [ "/persist/data/acme" ];
          serviceConfig.BindPaths = mkForce [
            "/persist/data/acme:/var/lib/acme"
            "/var/lib/acme/.minica:/tmp/ca"
          ];
        };
      };
  };
}
