{ stdenv, lib, fetchurl, fetchgit, runCommandNoCC, makeDesktopItem
, emacsGcc, libnotify, rnix-lsp, nixfmt, notmuch, graphviz
, direnv, dart, hunspell, python-language-server ? null
}@pkgs:
let
  emacs' = emacsGcc.overrideAttrs (attrs: {
    postInstall = (attrs.postInstall or "") + ''
      rm $out/share/applications/emacs{,-mail}.desktop
    '';
  });
  emacsPkgs = emacs'.pkgs.overrideScope' (prev: final: {
    emacs = emacs';
    #org = import ./org-mode.nix {
    #  inherit (final) emacs;
    #  inherit fetchgit;
    #};
    org = final.elpaPackages.org;
  });
  emacs = emacs' // { pkgs = emacsPkgs; };
  tangledConfig = runCommandNoCC "tangled-config" {
    nativeBuildInputs = [ emacs ];
  } ''
    mkdir -p $out
    cd $out
    cp ${./init.org} ./README.org
    emacs -Q --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "./README.org")'
  '';
  customConfig = runCommandNoCC "emacs-config" {} ''
    install -D ${tangledConfig}/init.el $out/share/emacs/site-lisp/default.el
  '';
  vika-theme = emacs.pkgs.trivialBuild {
    pname = "vika-theme";
    src = ./vika-theme.el;
  };
  # XXX not working
  speck-mode = emacs.pkgs.trivialBuild {
    pname = "speck-mode";
    src = fetchurl {
      url = "https://raw.githubusercontent.com/emacsmirror/emacswiki.org/efba30f7a4117a69090cf707e2dcf308c9c1d1cb/speck.el";
      sha256 = "ca6dcdeec65f130b531fef746092f793b75083d1a44902d40f9e06f5b27cc77e";
    };
  };
  org-protocol-desktop = makeDesktopItem { name = "emacsclient-org-protocol"; exec = "emacsclient -a \"\" %U"; desktopName = "Org Capture"; mimeType = ["x-scheme-handler/org-protocol"]; };
in (emacs.pkgs.withPackages (e: (with e; [
  evil
  evil-org

  aggressive-indent
  alert
  all-the-icons
  company
  company-nixos-options
  company-posframe
  counsel
  #dart-mode
  dashboard
  diminish
  exwm
  fancy-battery
  flycheck
  e."git-gutter-fringe+"
  htmlize
  hydra
  ivy
  #lsp-dart
  lsp-mode
  lsp-ui
  magit
  mixed-pitch
  multi-vterm
  #nix-mode # TODO: which nix version?
  ol-notmuch
  org
  org-appear
  org-contrib
  org-pomodoro
  org-super-agenda
  org-superstar
  org-roam
  page-break-lines
  rustic
  spaceline
  #speck-mode
  swiper
  telephone-line
  tron-legacy-theme
  undo-tree
  vterm
  yasnippet
  doom-themes
  elixir-mode
]) ++ [
  # Custom config for Emacs
  customConfig
  vika-theme
  # Other programs
  #dart
  direnv e.direnv
  graphviz
  hunspell
  libnotify
  nixfmt
  notmuch notmuch.emacs
  # rnix-lsp # TODO: which nix version

] ++ (lib.optionals (stdenv.targetPlatform == "x86_64-linux") [
  e.lsp-python-ms python-language-server
])
)).overrideAttrs (_: {
  meta = _.meta // { mainProgram = "emacs"; };
  passthru = (_.passthru or {}) // {
    inherit emacs org-protocol-desktop;
    pkgs = emacsPkgs;
  };
})
