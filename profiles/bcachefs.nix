{ pkgs, lib, ... }: {
  boot.initrd.supportedFilesystems = [ "vfat" "bcachefs" ];
  boot.supportedFilesystems = [ "bcachefs" "cifs" "vfat" "xfs" ];

  # FIXME: Remove this line when the default kernel has bcachefs
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  /* boot.kernelPatches = [{
       name = "bcachefs-config";
       patch = null;
       extraConfig = ''
         BCACHEFS_QUOTA y
         BCACHEFS_POSIX_ACL y
       '';
       # extra config is inherited through boot.supportedFilesystems
     }];
  */

  services.fstrim.enable = true;
}
