{ mkShell, linux, pkg-config, ncurses, rust-bin, rust-version ? "1.81.0"
, rustAttrs ? rust-bin.stable.${rust-version}, rust-bindgen }:

mkShell {
  name = "linux";

  inputsFrom = [ linux ];

  nativeBuildInputs = [
    pkg-config
    ncurses

    (rustAttrs.default.override {
      extensions = [ "rust-src" "rust-analyzer" ];
    })
    rust-bindgen
  ];

  hardeningDisable =
    [ "bindnow" "format" "fortify" "stackprotector" "pic" "pie" ];
}
