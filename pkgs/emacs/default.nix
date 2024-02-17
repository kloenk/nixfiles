{ emacsPackagesFor, emacs, runCommandNoCC }:

let
  emacsWithPkgs = (emacsPackagesFor emacs).emacsWithPackages (epkgs:
    with epkgs; [
      vterm
      exec-path-from-shell

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
      rustic

      flymake-elixir
      elixir-mode
      cmake-mode
      dts-mode

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
      magit-todos
    ]);
  tangledConfig = runCommandNoCC "tangled-config" {
    nativeBuildInputs = [ emacsWithPkgs ];
  } ''
    mkdir -p $out
    cd $out
    cp ${./Emacs.org} Emacs.org
    emacs -Q --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "./Emacs.org")'
  '';
  compiledConfig = runCommandNoCC "compile-config" {
    nativeBuildInputs = [ emacsWithPkgs ];
  } ''
    mkdir -p $out
    cp ${tangledConfig}/Emacs.el ${tangledConfig}/early-init.el .
    emacs -Q --batch --eval '(byte-compile-file "Emacs.el")' --eval '(byte-compile-file "early-init.el")'
    mv Emacs.elc init.elc
    cp *.elc $out/
  '';
in emacsWithPkgs // { passthru = { inherit tangledConfig compiledConfig; }; }
