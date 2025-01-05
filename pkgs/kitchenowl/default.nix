{ callPackage, flutter327, ... }@env: {
  kitchenowl-desktop = callPackage ./flutter.nix ({
    targetFlutterPlatform = "linux";
    flutter = flutter327;
  } // env);
  kitchenowl-web = callPackage ./flutter.nix ({
    targetFlutterPlatform = "web";
    flutter = flutter327;
  } // env);
  kitchenowl-backend = callPackage ./backend.nix env;
}

