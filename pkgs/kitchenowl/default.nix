{ callPackage, ... }@env: {
  kitchenowl-desktop =
    callPackage ./flutter.nix ({ targetFlutterPlatform = "linux"; } // env);
  kitchenowl-web =
    callPackage ./flutter.nix ({ targetFlutterPlatform = "web"; } // env);
  kitchenowl-backend = callPackage ./backend.nix env;
}

