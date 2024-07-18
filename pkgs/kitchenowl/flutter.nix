{ lib, flutter, fetchFromGitHub, util-linux, targetFlutterPlatform ? "linux"
, ... }:

let
  srcJson = lib.importJSON ./source.json;
  version = srcJson.version;
  src = fetchFromGitHub srcJson.src;

in flutter.buildFlutterApplication {
  pname = "kitchenowl-${targetFlutterPlatform}";
  inherit version src targetFlutterPlatform;

  postPatch = ''
    cd kitchenowl
  '';

  pubspecLock = lib.importJSON ./pubspec.lock.json;
} // lib.optionalAttrs (targetFlutterPlatform == "linux") {
  runtimeDependencies = [ util-linux ];
} // lib.optionalAttrs (targetFlutterPlatform == "web") { }
