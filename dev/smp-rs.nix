{ lib, stdenv, mkShell, rustc, cargo, rust-analyzer, nixfmt, rustfmt, pkg-config
, udev, libiconv }:
mkShell {
  nativeBuildInputs = [ rustc cargo rust-analyzer nixfmt rustfmt ]
    ++ lib.optional stdenv.isLinux [ pkg-config ];
  buildInputs = (lib.optional stdenv.isDarwin libiconv)
    ++ lib.optional stdenv.isLinux udev;
}
