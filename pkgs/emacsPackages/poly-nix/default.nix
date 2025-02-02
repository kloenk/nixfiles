{ trivialBuild, polymode, nix-mode }:

trivialBuild {
  pname = "poly-nix";
  src = ./.;
  version = "0.0.1";
  packageRequires = [ polymode nix-mode ];
}
