{ pkgs, ... }:
#(pkgs.buildFHSEnv {
#  name = "linux";
#  targetPkgs = _:
#    with pkgs;
#      [
#        pkgconfig
#        ncurses
#        (rust-bin.stable."1.72.0".default.override {
#          extensions = ["rust-src"];
#        })
#        rust-bindgen
#        #b4
#      ];
#      #++ pkgs.linux.nativeBuildInputs;
#})
#.env
#

pkgs.mkShell {
  buildInputs = with pkgs;
    [
      (rust-bin.stable."1.72.0".default.override {
        extensions = [ "rust-src" ];
      })
      rust-bindgen

      gnumake
      binutils
      gnused

      pkg-config
      ncurses
      libelf

      llvmPackages.clang
      llvmPackages.lld
      llvmPackages.bintools
      llvmPackages.llvm
    ] ++ pkgs.lib.optional pkgs.stdenv.isDarwin pkgs.libiconv
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux (pkgs.linux.buildInputs ++ pkgs.linux.nativeBuildInputs);

  shellHook = ''
    alias ls=exa
    alias find=fd
  '';
}
