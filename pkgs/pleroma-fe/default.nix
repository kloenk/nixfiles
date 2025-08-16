{ lib, stdenvNoCC, fetchFromGitLab, mkYarnPackage, fetchYarnDeps, yarnConfigHook
, yarnBuildHook, yarnInstallHook, nodejs

, be-config ? { }, formats }:

let
  json = formats.json { };
  config = (builtins.fromJSON (builtins.readFile ./static-config.json))
    // be-config;
  config-json = json.generate "config.json" config;
in stdenvNoCC.mkDerivation (final: {
  name = "pleroma-fe";

  version = "2.8.0";
  src = fetchFromGitLab {
    owner = "pleroma";
    repo = "pleroma-fe";
    rev = final.version;
    domain = "git.pleroma.social";
    hash = "sha256-GxC6FjbqJvTMy1EFnCJ8iuglNGCXeUf3P7XuWKjqeQ4=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${final.src}/yarn.lock";
    hash = "sha256-4m9fiFrjkLT0qTzqu14QMorAgpPlxZ14q+VX5l+nvfw=";
  };

  nativeBuildInputs = [ yarnConfigHook nodejs ];

  patchPhase = ''
    ln -sf ${config-json} ./public/static/config.json
  '';

  buildPhase = ''
    echo "running yarn build"
    yarn build --outDir "$out"
  '';

  doCheck = false; # Failing in a nix build
  checkPhase = ''
    yarn unit
  '';
})
