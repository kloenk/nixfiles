inputs: final: prev:
let inherit (final) callPackage;
in {

  wallpapers = callPackage ./wallpapers { };

  nu_kloenk = callPackage ./nu_scripts { };

  vemacs = callPackage ./vemacs { };
  vemacsMac = callPackage ./vemacs/mac.nix { };

  kloenk-emacs = callPackage ./emacs { emacs = final.emacs29-pgtk; };
  emacs-config = callPackage ./emacs-config { emacs = final.emacs29-pgtk; };

  obs-tuna = final.qt6Packages.callPackage ./obs-tuna { };

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

  ubootElros = callPackage ./ubootElros { };
}
