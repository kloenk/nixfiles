{ callPackage }:

{
  kismet-antispam = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkDerivation {
    name = "Kismet-Anti-Spam";
    src = fetchurl {
      url = "https://downloads.wordpress.org/plugin/akismet.4.1.7.zip";
      sha256 = "78aa519733670e8563db466c21ea9c54102ab00b598709a1537149387dec07b8";
    };
    buildInputs = [ unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  }) {};
  contactForm = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkDerivation {
    name = "Contact-Form-7";
    src = fetchurl {
      url = "https://downloads.wordpress.org/plugin/contact-form-7.5.3.2.zip";
      sha256 = "0d6de097344fec580fc908c80f843ee59c9fec6082d5df667ada2edf2045492e";
    };
    buildInputs = [ unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  }) {};
  backItUp = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkDerivation {
    name = "wpBackItUp";
    src = fetchurl {
      url = "https://downloads.wordpress.org/plugin/wp-backitup.1.40.0.zip";
      sha256 = "fe109ab81bf34a005c9b53bf87b2382d37fe0d21207226162d8df6c758c702cd";
    };
    buildInputs = [ unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  }) {};
}
