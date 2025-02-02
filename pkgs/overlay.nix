inputs: final: prev:
let inherit (final) callPackage;
in {
  alterpcb-tlineslim = callPackage ./alterpcb-tlinesim { };

  wallpapers = callPackage ./wallpapers { };

  nu_kloenk = callPackage ./nu_scripts { };

  vemacs = callPackage ./vemacs { };
  vemacsMac = callPackage ./vemacs/mac.nix { };

  kloenk-emacs = callPackage ./emacs { emacs = final.emacs29-pgtk; };
  emacs-config = callPackage ./emacs-config { emacs = final.emacs29-pgtk; };

  emacsPackages = prev.emacsPackages
    // (prev.emacsPackages.callPackage ./emacsPackages { });

  partlint = callPackage ./partlint { };
  homebox = callPackage ./homebox { };

  inherit (callPackage ./kitchenowl { python3 = final.python312; })
    kitchenowl-backend kitchenowl-desktop kitchenowl-web;

  obs-tuna = final.qt6Packages.callPackage ./obs-tuna { };

  kernel_rootfs = import (final.path + "/nixos/lib/make-disk-image.nix") {
    config = (import (final.path + "/nixos/lib/eval-config.nix") {
      inherit (final) system;
      modules = [{ imports = [ ./kernel_rootfs.nix ]; }];
    }).config;
    pkgs = final;
    inherit (final) lib;
    diskSize = 4096;
    partitionTableType = "none";
    format = "qcow2";
  };

  # helix = prev.helix.overrideAttrs
  #   (oldAttrs: rec { patches = oldAttrs.patches ++ [ ./helix-etc.patch ]; });

  matrix-to = callPackage ./matrix-to { };

  update-ssh-host-keys = callPackage ./update-ssh-host-keys { };

  evremap = callPackage ./evremap { };

  inventree = callPackage ./inventree {
    python3 = final.python3.override {
      packageOverrides = callPackage ./inventree/py-overrides.nix { };
    };
  };

  moodle = callPackage ./moodle { };

  ubootElros = callPackage ./ubootElros { };
}
