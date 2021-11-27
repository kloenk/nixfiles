{  }:

let
  makeDarwin = { user ? "kloenk", ... }@extraArgs:
    ({
      darwin = true;
      system = "aarch64-darwin";
      inherit user;
    } // extraArgs);
in {
  frodo = makeDarwin { };
}
