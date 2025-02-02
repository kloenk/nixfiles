{ lib, buildGoModule, fetchFromGitHub, pnpm, nodejs, go, git, cacert, }:
let
  pname = "homebox";
  version = "0.13.0";
  src = fetchFromGitHub {
    owner = "sysadminsmedia";
    repo = "homebox";
    rev = "4cb4d20ccb6d6e5851a37b6603235670cca78cc5";
    hash = "sha256-pjQPkwHCzu9kKceOOW5tmw4oqxjcldu1vNJw6/gMzyQ=";
  };
in buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-D9fMpOZ2/jp3M6i0g2bAWySAoefkf/gnl1avUG9rvBY=";
  modRoot = "backend";
  # the goModules derivation inherits our buildInputs and buildPhases
  # Since we do pnpm thing in those it fails if we don't explicitely remove them
  overrideModAttrs = _: {
    nativeBuildInputs = [ go git cacert ];
    preBuild = "";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version;
    src = "${src}/frontend";
    hash = "sha256-8KbKpkfzNmCsv170xIRGL9T/EKGZjeHWph26Yb+LGVU=";
  };
  pnpmRoot = "../frontend";

  env.NUXT_TELEMETRY_DISABLED = 1;

  preBuild = # sh shell=bash
    ''
      pushd ../frontend

      pnpm build

      popd

      mkdir -p ./app/api/static/public
      cp -r ../frontend/.output/public/* ./app/api/static/public
    '';

  nativeBuildInputs = [ pnpm pnpm.configHook nodejs ];

  CGO_ENABLED = 0;
  GOOS = "linux";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-extldflags=-static"
    "-X main.version=${version}"
    "-X main.commit=${version}"
  ];

  meta = {
    mainProgram = "api";
    homepage = "https://hay-kot.github.io/homebox/";
    description = "Inventory and organization system built for the Home User";
    maintainers = with lib.maintainers; [ patrickdag ];
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
  };
}
