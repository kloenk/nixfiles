inputs: final: prev:
let inherit (final) callPackage;
in {
  collectd-wireguard = callPackage ./collectd-wireguard { };
  jblock = callPackage ./jblock { };
  deploy_secrets = callPackage ./deploy_secrets { };
  wallpapers = callPackage ./wallpapers { };
  fabric-server = callPackage ./fabric-server { };
  pam_nfc = callPackage ./pam_nfc { };

  libnfc0 = callPackage ./libnfc { };

  redshift = prev.redshift.overrideAttrs (oldAttrs: rec {
    src = final.fetchFromGitHub {
      owner = "minus7";
      repo = "redshift";
      rev = "eecbfedac48f827e96ad5e151de8f41f6cd3af66";
      sha256 = "0rs9bxxrw4wscf4a8yl776a8g880m5gcm75q06yx2cn3lw2b7v22";
    };
  });

  spidermonkey_38 = null;

  mixnix = callPackage (inputs.mixnix + "/nix/mix2nix.nix") { };
  pleroma = callPackage ./pleroma { };

  #let source = callPackage ./sourcegraph { }; in inherit (source) ;
  inherit (callPackage ./sourcegraph { }) sourcegraph_go sourcegraph_web;

  inherit (final.callPackage ./firefox { })
    firefoxPolicies firefox-policies-wrapped;

  nix-serve = prev.nix-serve.overrideAttrs (oldAttrs: rec {
    meta = oldAttrs.meta // { platforms = final.lib.platforms.linux; };
  });

  rustc_nightly = prev.rustc.overrideAttrs (oldAttrs: {
    configureFlags = map (flag:
      if flag == "--release-channel=stable" then
        "--release-channel=nightly"
      else
        flag) oldAttrs.configureFlags;
  });

  linux_rust = let
    linux_rust_pkg = { fetchFromGitHub, buildLinux, clang_11, llvm_11
      , rustc_nightly, cargo, ... }@args:
      buildLinux (args // rec {
        version = "5.9.0-rc2";
        modDirVersion = version;

        src = fetchFromGitHub {
          owner = "kloenk";
          repo = "linux";
          rev = "cc175e9a774a4b758029c1e6ca69db00b5e19fdc";
          sha256 = "sha256-EYCVtEd2/t98d0UbmINlMoJuioRqD3ZxrSVMADm22SE=";
        };
        kernelPatches = [ ];

        extraNativePackages = [ clang_11 llvm_11 rustc_nightly cargo ];

        extraMeta.branch = "5.9";

      } // (args.argsOverride or { }));
  in callPackage linux_rust_pkg { };

  emacs-doom = callPackage ./emacs { };

  wordpressPlugins = {
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
  };
  wordpressThemes = {
    twentyTwelf = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkOverride {
      name = "twentyTwelf";
      src = fetchurl {
        url = "https://downloads.wordpress.org/theme/twentytwelve.3.3.zip";
        sha256 = "9a57d135b166efe12b2e8ef45f0bfac1c5ef9b59cfaab447e0d10a5eff9aaaad";
      };
      buildInputs = [ unzip ];
      installPhase = "mkdir -p $out; cp -R * $out/";
    }) {};
    twentFourteen = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkOverride {
      name = "twentyFourteen";
      src = fetchurl {
        url = "https://downloads.wordpress.org/theme/twentyfourteen.3.0.zip";
        sha256 = "dd17fdff5322b30492aa1bda8f01eef5b45d5165c58944a719eb7483ceccbcec";
      };
      buildInputs = [ unzip ];
      installPhase = "mkdir -p $out; cp -R * $out/";
    }) {};
    twentyFifteen = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkOverride {
      name = "twentyFifteen";
      src = fetchurl {
        url = "https://downloads.wordpress.org/theme/twentyfifteen.2.8.zip";
        sha256 = "84696f84b9b5b3671596fec82033eb3c44703b9aa59c67c134543eb43720edf5";
      };
      buildInputs = [ unzip ];
      installPhase = "mkdir -p $out; cp -R * $out/";
    }) {};
    twentySixteen = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkOverride {
      name = "twentySixteen";
      src = fetchurl {
        url = "https://downloads.wordpress.org/theme/twentysixteen.2.3.zip";
        sha256 = "c3db11052781516e35c27927bff5b0a85cc00ced0674a2590b79ea5f7cbe3e03";
      };
      buildInputs = [ unzip ];
      installPhase = "mkdir -p $out; cp -R * $out/";
    }) {};
    twentyNineteen = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkOverride {
      name = "twentyNineteen";
      src = fetchurl {
        url = "https://downloads.wordpress.org/theme/twentynineteen.1.9.zip";
        sha256 = "93f49a80881fcaf3cd3cc51ac4d905249f82b35808ce313c716aea3009bdaf1a";
      };
      buildInputs = [ unzip ];
      installPhase = "mkdir -p $out; cp -R * $out/";
    }) {};
    twentyTwenty = callPackage ({ fetchurl, stdenv, unzip }: stdenv.mkOverride {
      name = "twentyTwenty";
      src = fetchurl {
        url = "https://downloads.wordpress.org/theme/twentytwenty.1.6.zip";
        sha256 = "57f5b927bfd3e3044b8ea66b1ac213a700ed6753aa65fce786b5267a1103685f";
      };
      buildInputs = [ unzip ];
      installPhase = "mkdir -p $out; cp -R * $out/";
    }) {};
  };
}
