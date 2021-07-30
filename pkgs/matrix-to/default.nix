{ fetchFromGitHub, mkYarnPackage }:

mkYarnPackage rec {
  pname = "matrix.to";
  version = "1.2.11";
  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "matrix.to";
    rev = version;
    sha256 = "sha256-+DVyITD4BA5YcU9aanLfm/QoYbsoRNzz5cjwXByLqdA=";
  };
  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;

  buildPhase = ''
    yarn --offline --frozen-lockfile build
  '';
  installPhase = ''
    mkdir $out
    mv deps/matrix.to/build/* "$out"
  '';
  distPhase = "true";
}