{ lib, runCommandNoCC, substituteAll, bash, coreutils, pass, gnupg }:

let
  pass_nix = substituteAll {
    name = "pass-nix";
    version = "0.0.1";

    src = ./pass-nix.sh;
    isExecutable = true;

    path = lib.makeBinPath [ coreutils pass gnupg ];

    meta = { license = lib.licenses.mit; };
  };
in runCommandNoCC "pass-nix" { } ''
  mkdir -p $out/bin
  cp ${pass_nix} $out/bin/pass-nix
''
