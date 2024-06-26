final: prev:

# Insipred by deterministic pseudorandom port allocator by alina (cyberchaos.dev/alina/flake)

let lib = final;
in {
  minPort = 5000;
  maxPort = 65535;
  alphabet = "abcdefghijklmnopqrstuvwxyz";
  __functor = { minPort, maxPort, alphabet, ... }:
    service:
    let
      hash = builtins.hashString "sha256" service;
      charList =
        map lib.strings.charToInt (lib.strings.stringToCharacters hash);
      num = lib.lists.foldl (a: b: a + (b * minPort)) 0 charList;
    in (lib.mod num (maxPort - minPort)) + minPort;
}

