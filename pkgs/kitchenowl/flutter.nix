{ lib, flutter, fetchFromGitHub, util-linux, imagemagick, makeDesktopItem
, targetFlutterPlatform ? "linux", ... }:

let
  srcJson = lib.importJSON ./source.json;
  version = srcJson.version;
  src = fetchFromGitHub srcJson.src;

in flutter.buildFlutterApplication ({
  pname = "kitchenowl-${targetFlutterPlatform}";
  inherit version src targetFlutterPlatform;

  postPatch = ''
    cd kitchenowl
  '';

  pubspecLock = lib.importJSON ./pubspec.lock.json;
} // lib.optionalAttrs (targetFlutterPlatform == "linux") {
  nativeBuildInputs = [ imagemagick ];
  runtimeDependencies = [ util-linux ];

  desktopItem = makeDesktopItem {
    name = "kitchenOwl";
    exec = "kitchenowl";
    icon = "kitchenowl";
    desktopName = "kitchenOwl";
    genericName = "smart grocery list and recipe manager";
    categories = [ "Office" "Utility" "Finance" ];
    mimeTypes = [ "x-scheme-handler/kitchenowl" ];
  };

  postInstall = ''
    FAV=$out/app/data/flutter_assets/assets/icon/icon.png
    ICO=$out/share/icons

    install -D $FAV $ICO/kitchenowl.png
    mkdir $out/share/applications
    cp $desktopItem/share/applications/*.desktop $out/share/applications
    for size in 24 32 42 64 128 256 512; do
      D=$ICO/hicolor/''${s}x''${s}/apps
      mkdir -p $D
      convert $FAV -resize ''${size}x''${size} $D/kitchenowl.png
    done
  '';

} // lib.optionalAttrs (targetFlutterPlatform == "web") { })
