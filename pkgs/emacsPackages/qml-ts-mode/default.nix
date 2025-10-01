{ trivialBuild, fetchFromGitHub }:

trivialBuild {
  pname = "qml-ts-mode";
  version = "0-unstable-2025-07-01";
  src = fetchFromGitHub {
    owner = "xhcoding";
    repo = "qml-ts-mode";
    rev = "b80c6663521b4d0083e416e6712ebc02d37b7aec";
    hash = "";
  };
}
