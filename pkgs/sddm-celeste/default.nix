{ stdenvNoCC, fetchFromGitHub, kdePackages, p7zip,

runCommandNoCC, jdk, fetchzip, requireFile, }:
let
  basePath = "$out/share/sddm/themes/celeste-sddm";

  celestAssets = requireFile {
    name = "FileSelect0.data";
    url =
      "/home/kloenk/.steam/steam/steamapps/common/Celeste/Content/Graphics/Atlases/";
    hash = "sha256-/vv0ZtKfnY3xHJR3z2w+ezlYVMX/NiLIR9ZElf3j8xE=";
  };
  celesteExtractor = fetchzip {
    url =
      "https://github.com/TeWu/CelesteExtractor/releases/download/v1.0.0/CelesteExtractor_v1.0.0.zip";
    stripRoot = false;
    hash = "sha256-QyFiIUQWng6P2Ec780lurTi0LCakH08qwZvjyq98ihE=";
  };

  assets =
    runCommandNoCC "FileSelect0.data.png" { nativeBuildInputs = [ jdk ]; } ''
      java -jar ${celesteExtractor}/CelesteExtractor.jar ${celestAssets} $out
    '';
in stdenvNoCC.mkDerivation (final: {
  pname = "sddm-celeste ";
  version = "0.0-unstable-2022-12-29";

  src = fetchFromGitHub {
    #owner = "Mingy123";
    owner = "kloenk";
    repo = "celeste-sddm";
    rev = "87f658c7b9e7b3651c76de77c667238bc2703505";
    hash = "sha256-sVFrKf/20EstEEaEB2f/sRWiEX1yDa+vt9gSI7Xb1rk=";
  };

  #src = /home/kloenk/Developer/qt/celeste-sddm;

  dontWrapQtApps = true;

  propagatedBuildInputs = with kdePackages; [ phonon qtmultimedia ];

  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    mkdir -p ${basePath}
    cp -r $src/* ${basePath}
    pushd ${basePath}/assets
    chmod +w .
    if [ ! -f background.mp4 ]; then
        7z x -sdel out.zip.001
    fi
    rm out.zip.*
    cp ${assets} FileSelect0.data.png
    popd
  '';

  passthru = { inherit assets; };
})
