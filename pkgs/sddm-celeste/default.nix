{ stdenvNoCC, fetchFromGitHub, kdePackages, libsForQt5, gst_all_1, p7zip }:
let basePath = "$out/share/sddm/themes/celeste-sddm";
in stdenvNoCC.mkDerivation (final: {
  pname = "sddm-celeste ";
  version = "0.0-unstable-2022-12-29";

  src = fetchFromGitHub {
    owner = "Mingy123";
    repo = "celeste-sddm";
    rev = "ed86f11d883b97a1b6a37e23e76423e3e4fd8d56";
    hash = "sha256-3zKmab4Q2OFIDU6F5BGUJ9tRFlNnNOruJm5PNVwPVyk=";
  };

  dontWrapQtApps = true;

  propagatedBuildInputs = [ gst_all_1.gst-libav gst_all_1.gst-plugins-good ]
    ++ (with libsForQt5; [
      phonon-backend-gstreamer
      qt5.qtquickcontrols
      qt5.qtgraphicaleffects
      qt5.qtmultimedia
    ]) ++ (with kdePackages;
      [
        phonon
        #qtmultimedia
      ]);

  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    mkdir -p ${basePath}
    cp -r $src/* ${basePath}
    pushd ${basePath}/assets
    chmod +w .
    7z x -sdel out.zip.001
    rm out.zip.*
    popd
  '';
})
