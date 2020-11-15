{ callPackage, waylandPkgs, emacsPackagesFor }:

callPackage (builtins.fetchGit {
  url = "https://github.com/vlaci/nix-doom-emacs/";
  rev = "94e263dc29a59847726ebb3b668088db041950c5";
}) {
  doomPrivateDir = "${./doom.d}";
  emacsPackages = emacsPackagesFor waylandPkgs.emacs-pgtk;
}
  #nix-mode
  #rust-mode
