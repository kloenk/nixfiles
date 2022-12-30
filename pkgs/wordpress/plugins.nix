{ callPackage }:

let
  buildPlugin = { name ? builtins.baseNameOf url, url, sha256, ... }@extraArgs:
    callPackage ({ fetchurl, stdenv, unzip }:
      stdenv.mkDerivation {
        inherit name;
        src = fetchurl { inherit url sha256; };
        buildInputs = [ unzip ];
        installPhase = "mkdir -p $out; cp -R * $out/";
      } // extraArgs) { };
in {
  kismet-antispam = buildPlugin {
    url = "https://downloads.wordpress.org/plugin/akismet.4.1.7.zip";
    sha256 = "78aa519733670e8563db466c21ea9c54102ab00b598709a1537149387dec07b8";
  };
  contactForm = buildPlugin {
    url = "https://downloads.wordpress.org/plugin/contact-form-7.5.3.2.zip";
    sha256 = "0d6de097344fec580fc908c80f843ee59c9fec6082d5df667ada2edf2045492e";
  };
  backItUp = buildPlugin {
    url = "https://downloads.wordpress.org/plugin/wp-backitup.1.40.0.zip";
    sha256 = "fe109ab81bf34a005c9b53bf87b2382d37fe0d21207226162d8df6c758c702cd";
  };
  antispamBee = buildPlugin {
    url = "https://downloads.wordpress.org/plugin/antispam-bee.2.9.3.zip";
    sha256 = "9349c4c12403c6fc41153eb61a953f10dd9f401d173f37b23ee13dcc7890f0fe";
  };

  podlove = {
    publisher = buildPlugin {
      url =
        "https://downloads.wordpress.org/plugin/podlove-podcasting-plugin-for-wordpress.3.2.2.zip";
      sha256 =
        "bae104fe1a36c8326251a27d65b69419762f5ead83fd0c182c1df7f8449b21fa";
    };
    button = buildPlugin {
      url =
        "https://downloads.wordpress.org/plugin/podlove-subscribe-button.1.3.7.zip";
      sha256 =
        "a475797f2c4b6d557b464ee82f839c5c16a90527ea406aebe03d83b42da57d3e";
    };
    player = buildPlugin {
      url = "https://downloads.wordpress.org/plugin/podlove-web-player.zip";
      sha256 =
        "c6d96e5c407835edaadff7b075f4224badfbe48481f285d2d4e2b4967cd80f91";
    };
  };

  elementor = buildPlugin {
    url = "https://downloads.wordpress.org/plugin/elementor.3.0.16.zip";
    sha256 = "d6f971db4a8f3a335287c2d01e2c480236e5fc6bcdaf4e7c103bef52fc78df91";
  };
  wpforms = buildPlugin {
    url = "https://downloads.wordpress.org/plugin/wpforms-lite.1.6.4.1.zip";
    sha256 = "8b8a4edf8030e494f7cec02a971b36053631a4440e2afaa51f32afb440df312e";
  };

  woocomerce = buildPlugin {
    url = "https://downloads.wordpress.org/plugin/woocommerce.5.0.0.zip";
    sha256 = "58172b18ec17ef795a2cb9f10764d0d1fa6174d981749800791ddccdc6316c79";
  };

  language-de = callPackage ({ fetchzip, stdenv, unzip }:
    stdenv.mkDerivation {
      name = "language-de";
      src = fetchzip {
        url = "https://de.wordpress.org/wordpress-5.6.1-de_DE.tar.gz";
        sha256 = "sha256-b0JY8RKBThJbdYxXbH3AOThKQahq9UHBhytTnfkM7wU=";
      };

      buildInputs = [ unzip ];
      buildPhase = "ls";
      installPhase = "mkdir -p $out; cp -R ./wp-content/languages/* $out";
    }) { };

  woocomerce-de = callPackage ({ fetchzip, stdenv, unzip }:
    stdenv.mkDerivation {
      name = "woocomerce-de";
      src = fetchzip {
        url =
          "https://downloads.wordpress.org/translation/plugin/woocommerce/5.0.0/de_DE.zip";
        sha256 = "sha256-hfgd8+Zj71wFXj+GMP9QaF70AOzv/1tVHGcqc97YgUM=";
        stripRoot = false;
      };

      buildInputs = [ unzip ];
      installPhase = "mkdir -p $out/woocommerce; cp -R * $out/woocommerce/";
    }) { };

  /* kismet-antispam = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkDerivation {
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
     antispamBee = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkDerivation {
       name = "antispamBee";
       src = fetchurl {
         url = "";
         sha256 = "";
       };
       buildInputs = [ unzip ];
       installPhase = "mkdir -p $out; cp -R * $out/";
     }) {};
  */
}
