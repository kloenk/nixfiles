{ lib, stdenv, fetchgit, obs-studio, cmake, pkg-config, zlib, curl, dbus, qtbase
}:

stdenv.mkDerivation rec {
  pname = "obs-tuna";
  version = "v1.9.4";

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ obs-studio zlib curl dbus qtbase ];

  src = fetchgit {
    url = "https://git.vrsal.xyz/alex/tuna";
    rev = version;
    sha256 = "sha256-3MFqzeBqjpxH5DtiEUdKRaL1yEX8yyB1Zht97vNARe8=";
  };

  dontWrapQtApps = true;

  postInstall = ''
    mkdir $out/lib $out/share
    mv $out/obs-plugins/64bit $out/lib/obs-plugins
    rm -rf $out/obs-plugins
    mv $out/data $out/share/obs
  '';
}
