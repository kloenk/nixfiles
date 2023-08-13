{ stdenv, nushell }:

stdenv.mkDerivation {
  name = "nu_scripts";

  src = ./.;

  buildPhase = ''
    rm default.nix
    ${nushell}/bin/nu -c 'if (nu-check kloenk.nu) == false { error make { msg: "invalid config" }}'
  '';

  installPhase = ''
    mkdir -p $out/share/nu_scripts
    cp -r * $out/share/nu_scripts
  '';
}
