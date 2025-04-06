{ rustPlatform, fetchFromGitHub, pkg-config, libevdev }:

rustPlatform.buildRustPackage {
  pname = "evremap";
  version = "unstable-2024-02-21";
  src = fetchFromGitHub {
    owner = "wez";
    repo = "evremap";
    rev = "cc618e8b973f5c6f66682d1477b3b868a768c545";
    hash = "sha256-aAAnlGlSFPOK3h8UuAOlFyrKTEuzbyh613IiPE7xWaA=";
  };

  #cargoHash = "sha256-RsoK++j6NWQKjrF13bpNS0nJP17sPCiO6jjY4+HucS0=";
  cargoHash = "sha256-3KXvRbPHM78IGe7Hl8AEHCmK0onroQycyTfOm942e9Y=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libevdev ];
}
