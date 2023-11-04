{ pkgs, lib, ... }: {
  boot.supportedFilesystems = [ "bcachefs" "cifs" "vfat" "xfs" ];
# working:
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (pkgs.linux_6_6.override {
    argsOverride = rec {
      src = pkgs.fetchFromGitHub {
        owner = "koverstreet";
        repo = "bcachefs";
        rev = "b9bd69421f7364ca4ff11c827fd0e171a8b826ea";
        hash = "sha256-XQtYCo4GXXf5j41RI3djtmylm9sBsrRqdpiU4M7s52I=";
      };
      version = "6.6.0";
      modDirVersion = "6.6.0";
    };
  }));
}