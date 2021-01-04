# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/bilbo/root";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/98F3-1C11";
      fsType = "vfat";
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/8c7fd4d3-a14f-4210-a020-1c4f82e6202a";
      fsType = "xfs";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/bb02e160-65d2-4eeb-86ac-f3f5ed636d07";
      fsType = "xfs";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 2;
}