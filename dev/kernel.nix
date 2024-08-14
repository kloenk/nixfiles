{ mkShell, linux, pkg-config, ncurses, rust-bin, rust-version ? "1.78.0"
, rustAttrs ? rust-bin.stable.${rust-version}, rust-bindgen }:

mkShell {
  name = "linux";

  inputsFrom = [ linux ];

  nativeBuildInputs = [
    pkg-config
    ncurses

    (rustAttrs.default.override { extensions = [ "rust-src" ]; })
    rust-bindgen
  ];

  hardeningDisable =
    [ "bindnow" "format" "fortify" "stackprotector" "pic" "pie" ];
}
