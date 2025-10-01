{ lib, fetchFromGitHub, rustPlatform, rust-analyzer, rustfmt }:

rustPlatform.buildRustPackage {
  pname = "sniproxy";
  version = "0-unstable-2025-09-08";

  nativeBuildInputs = [ rust-analyzer rustfmt ];

  /* src = fetchFromGitHub {
       owner = "atenart";
       repo = "sniproxy";
       rev = "7aa6fe6be8cb2d962da9575ff3875414115fbf9f";
       hash = "sha256-6TOHHxzZkQyn7D4q30Y0ClVwXovjd+QBUzdRtVDEiAk=";
     };
  */
  src = fetchFromGitHub {
    owner = "kloenk";
    repo = "sniproxy";
    rev = "a761b1fc12979643610a4c23adf7fb65d4b3230d";
    hash = "sha256-H9xLehDNXm+Ba+3jbx+80FFcKuJA1cagGiJvKUsM/7s=";
  };

  cargoHash = "sha256-H4RyA/2auxGIZoXutLwJSTgKcW4ijQtglsBtPox+UKo=";

  meta = with lib; {
    homepage = "https://github.com/atenart/sniproxy";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    mainProgram = "sniproxy";
  };
}
