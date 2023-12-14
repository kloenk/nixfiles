

{ emacsPackagesFor, emacs, runCommandNoCC }:

let
  emacsWithPkgs = (emacsPackagesFor emacs).emacsWithPackages (epkgs:
    with epkgs; [
      vterm

      monokai-pro-theme
      spaceline
      dashboard
      ligature
      diminish
      counsel
      company
      helpful
      editorconfig
      direnv
      nix-mode
      protobuf-mode
      helm-nixos-options
      helm-projectile
      org-bullets
      # org-tempo
      org-make-toc
      treemacs
      treemacs-magit
      treemacs-projectile
      magit
    ]);
  compiledConfig = runCommandNoCC "compile-config" {
    nativeBuildInputs = [ emacsWithPkgs ];
  } ''
    cp ${./default.el} ./kloenk.el
    emacs -Q --batch --eval '(byte-compile-file "kloenk.el")'
    cp kloenk.elc $out
  '';
in emacsWithPkgs // { passthru = { config = compiledConfig; }; }
