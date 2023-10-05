{ lib, stdenv, runCommand, emacsWithPackagesFromUsePackage, emacs }:
 
/*let
in emacs.pkgs.withPackages (e: (with e; [
  evil
  evil-collection
  general
  command-log-mode
]))*/

let
  tangledConfig = runCommand "tangled-config" {
    nativeBuildInputs = [ emacs ];
  } ''
    mkdir -p $out
    cd $out
    cp ${./Emacs.org} Emacs.org
    emacs -Q --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "./Emacs.org")'
  '';
  defaultInit = runCommand "default.el" {
  } ''
    touch $out
    cat ${tangledConfig}/early-init.el >> $out
    cat ${tangledConfig}/init.el >> $out
  '';
in emacsWithPackagesFromUsePackage {
  # config = "${tangledConfig}/init.el";
  config = ./Emacs.org;
  # defaultInitFile = tangledConfig;
  defaultInitFile = defaultInit;
  package = emacs;
  alwaysTangle = true;
} // {
  passthru = {
    config = tangledConfig;
    init = defaultInit;
  };
}

