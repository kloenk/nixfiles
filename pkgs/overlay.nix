inputs: final: prev:
let inherit (final) callPackage;
in {

  wallpapers = callPackage ./wallpapers { };

  nu_kloenk = callPackage ./nu_scripts { };

  vemacs = callPackage ./vemacs { };
  vemacsMac = callPackage ./vemacs/mac.nix { };

  kloenk-emacs = callPackage ./emacs { emacs = final.emacs29-pgtk; };

  obs-tuna = final.qt6Packages.callPackage ./obs-tuna { };

  # helix = prev.helix.overrideAttrs
  #   (oldAttrs: rec { patches = oldAttrs.patches ++ [ ./helix-etc.patch ]; });

  matrix-to = callPackage ./matrix-to { };

  update-ssh-host-keys = callPackage ./update-ssh-host-keys { };

  evremap = callPackage ./evremap { };

  ubootElros = callPackage ./ubootElros { };
}
