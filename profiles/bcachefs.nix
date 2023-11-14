{ pkgs, lib, ... }: {
  boot.initrd.supportedFilesystems = [ "vfat" "bcachefs" ];
  boot.supportedFilesystems = [ "bcachefs" "cifs" "vfat" "xfs" ];

  # 6.7-rc1:
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_testing;

  boot.kernelPatches = [{
    name = "bcachefs-config";
    patch = null;
    extraConfig = ''
      BCACHEFS_QUOTA y
      BCACHEFS_POSIX_ACL y
    '';
    # extra config is inherited through boot.supportedFilesystems
  }];

  services.fstrim.enable = true;
}
