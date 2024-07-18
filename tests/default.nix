self: final: prev:
let inherit (final) callPackage;
in {
  kloenk-tests = {
    inventree = callPackage ./inventree { inherit self; };
    kitchenowl-backend = callPackage ./kitchenowl-backend { inherit self; };
  };
}
