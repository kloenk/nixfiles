{ llvmPackages, mkShell, linux, pkg-config, ncurses, python3, b4, rust-bin
, rust-version ? "1.81.0", rustAttrs ? rust-bin.stable.${rust-version}
, rust-bindgen }:

mkShell {
  name = "linux";

  inputsFrom = [ linux ];

  nativeBuildInputs = [
    (python3.withPackages (p: with p; [ ply gitpython ]))

    pkg-config
    ncurses

    b4

    llvmPackages.clang-tools

    (rustAttrs.default.override {
      extensions = [ "rust-src" "rust-analyzer" ];
    })
    rust-bindgen
  ];

  hardeningDisable =
    [ "bindnow" "format" "fortify" "stackprotector" "pic" "pie" ];
}
