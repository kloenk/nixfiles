{ pkgs, ... }:

{
  system.build.uboot = pkgs.ubootNanoPCT6.override {
    extraConfig = ''
      CONFIG_EFI_VARIABLE_FILE_STORE=n
      CONFIG_EFI_BOOTMGR=n
      CONFIG_CMD_NET=n

      CONFIG_EFI_VARIABLE_NO_STORE=y
      CONFIG_EFI_VARIABLES_PRESEED=y
      CONFIG_EFI_VAR_SEED_FILE="ubootefi.var"
      CONFIG_EFI_SECURE_BOOT=y
    '';
    postPatch = "cp ${./ubootefi.var} ./ubootefi.var";
    nativeBuildInputs = with pkgs;
      [ perl ] ++ pkgs.ubootNanoPCT6.nativeBuildInputs;
  };
}
