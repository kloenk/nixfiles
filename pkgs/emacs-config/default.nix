{ emacsPackagesFor, emacs, gitFull, runCommandNoCC, notmuch }:

let
  tangledConfig =
    runCommandNoCC "tangled-config" { nativeBuildInputs = [ emacs ]; } ''
      mkdir -p $out
      cd $out
      cp ${./Emacs.org} Emacs.org
      emacs -Q --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "./Emacs.org")'
      ls
    '';
  config = epkgs:
    epkgs.trivialBuild {
      pname = "default";
      src = tangledConfig;
      version = "0.1.0";
      packageRequires = import ./packages.nix epkgs;
    };
  emacsWithPkgs = (emacsPackagesFor emacs).emacsWithPackages
    (epkgs: [ (config epkgs) gitFull ]);
in emacsWithPkgs // {
  passthru = {
    inherit tangledConfig;
    config = config (emacsPackagesFor emacs);
  };
}
