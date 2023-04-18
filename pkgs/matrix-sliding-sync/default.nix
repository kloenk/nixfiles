{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "matrix-sliding-sync-proxy";
  version = "0.99.1";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "sliding-sync";
    rev = "v${version}";
    sha256 = "sha256-g1yMGb8taToEFG6N057yPcdZB855r0f6EwnJ98FIiic=";
  };

  subPackages = [ "cmd/syncv3" ];

  vendorSha256 = "sha256-FmibAVjKeJUrMSlhoE7onLoa4EVjQvjDI4oU4PB5LBE=";

  postInstall = ''
    mkdir -p $out/share
    cp -r ./client $out/share/client
  '';
}
