{ mkShell, cmake, ninja, dtc, wget, minicom, python3 }:

let
  # It's not entirely clear based on the documentation which of all of these
  # dependencies are actually necessary to build Zephyr, the list may increase
  # depending on the ongoing changes upstream
  zephyrPython = python3.withPackages (p:
    with p; [
      docutils
      wheel
      breathe
      sphinx
      sphinx_rtd_theme
      ply
      pyelftools
      pyserial
      #pykwalify
      colorama
      pillow
      intelhex
      pytest
      gcovr
      tkinter
      future
      cryptography
      setuptools
      pyparsing
      click
      kconfiglib
      pylink-square
      pyyaml
      cbor2
      west
      ecdsa
      anytree
      click
    ]);
in mkShell {
  nativeBuildInputs = [ cmake ninja dtc wget minicom zephyrPython ];
}
