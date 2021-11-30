{ lib, stdenv, fetchurl, fetchgit, ncurses, pkg-config, texinfo, libxml2, gnutls
, gettext, autoconf, automake, jansson, AppKit, Carbon, Cocoa, IOKit, OSAKit
, Quartz, QuartzCore, WebKit, UniformTypeIdentifiers, sigtool, ImageCaptureCore
, GSS, ImageIO # These may be optional
}:

stdenv.mkDerivation rec {
  pname = "emacs";
  version = "27.2-mac-8.3";

  src = fetchgit {
    url = "https://bitbucket.org/mituharu/emacs-mac.git";
    rev = "6c281ea549a9085a7ac68300a58c977945b0c12b";
    sha256 = "sha256-wLw9yGtbpmeggXfLLm/4CMppNFJwpxVh4yv2OWdwv08=";
  };

  patches = lib.optional stdenv.isAarch64 ./codesign.patch;

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkg-config autoconf automake ]
    ++ lib.optional stdenv.isAarch64 [ sigtool ];

  buildInputs = [
    ncurses
    libxml2
    gnutls
    texinfo
    gettext
    jansson
    AppKit
    Carbon
    Cocoa
    IOKit
    OSAKit
    Quartz
    QuartzCore
    WebKit
    ImageCaptureCore
    GSS
    ImageIO # may be optional
  ] ++ lib.optional stdenv.isAarch64 [ UniformTypeIdentifiers ];

  configureFlags = [
    "LDFLAGS=-L${ncurses.out}/lib"
    "--with-xml2=yes"
    "--with-gnutls=yes"
    "--with-mac"
    "--with-modules"
    "--enable-mac-app=$$out/Applications"
    "--prefix=$out"
  ];

  CFLAGS = "-O3";
  LDFLAGS = "-O3 -L${ncurses.out}/lib";

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp/
    cp ${./site-start.el} $out/share/emacs/site-lisp/site-start.el
  '';

  doCheck = false;

}
