{ lib, substituteAll, bash, coreutils, pass, gnupg }:

substituteAll {
  name = "pass-nix";
  version = "0.0.1";
  
  src = ./pass-nix.sh;
  isExecutable = true;
  
  path = lib.makeBinPath [ coreutils pass gnupg ];
  
  meta = { license = lib.licenses.mit; };
}
