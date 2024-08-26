{ lib, stdenv, fetchFromGitHub, libsForQt5, pkg-config, eigen, suitesparse, blas
, lapack }:

stdenv.mkDerivation {
  pname = "alterpcb-tlinesim";
  version = "unstable-2024-08-21";

  src = fetchFromGitHub {
    owner = "MaartenBaert";
    repo = "alterpcb-tlinesim";
    rev = "d4724c8a2ee8e4d2007177c586526ba5a70c0700";
    hash = "sha256-U10WY14/1oVvFT2su/8wYg7Z/06b0VgYjpfxj+bABYI=";
  };

  nativeBuildInputs = with libsForQt5; [ qmake wrapQtAppsHook pkg-config ];
  buildInputs = [ eigen suitesparse blas lapack ];

  qmakeFlags = [ "src" ];
}
