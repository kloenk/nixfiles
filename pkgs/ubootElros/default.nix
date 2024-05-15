{ fetchFromGitLab, ubootNanoPCT6, perl }:

let version = "2024.07-rc2";
in ubootNanoPCT6.override {
  src = fetchFromGitLab {
    owner = "u-boot";
    repo = "u-boot";
    rev = "v${version}";
    domain = "source.denx.de";
    hash = "sha256-1JUYBv/zJ22M3XuTrWXv23RvHHWTjxomD8ukZVVDPNE=";
  };
  inherit version;
  extraConfig = ''
    CONFIG_EFI_VARIABLE_FILE_STORE=n
    CONFIG_EFI_BOOTMGR=n
    CONFIG_CMD_NET=n

    CONFIG_EFI_VARIABLE_NO_STORE=y
    CONFIG_EFI_VARIABLES_PRESEED=y
    CONFIG_EFI_VAR_SEED_FILE="ubootefi.var"
    CONFIG_EFI_SECURE_BOOT=y
  '';
  postPatch = ubootNanoPCT6.postPatch + "cp ${./ubootefi.var} ./ubootefi.var";
  nativeBuildInputs = [ perl ] ++ ubootNanoPCT6.nativeBuildInputs;
  filesToInstall = [ "u-boot-rockchip-spi.bin" ]
    ++ ubootNanoPCT6.filesToInstall;
}
