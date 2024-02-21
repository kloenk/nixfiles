{ rustPlatform, fetchFromGitHub, pkg-config, libevdev }:

rustPlatform.buildRustPackage {
  pname = "evremap";
  version = "unstable-2024-02-21";
  src = fetchFromGitHub {
    owner = "wez";
    repo = "evremap";
    rev = "d0e8eb231fdeaf9c6457b36c1f04164150a82ad0";
    hash = "sha256-FRUJ2n6+/7xLHVFTC+iSaigwhy386jXccukoMiRD+bw=";
  };

  cargoHash = "sha256-B/mbKg5sviYc2Yk1C8OrkMQbls+CGcq0mQfNkSlIMTM=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libevdev ];
}
