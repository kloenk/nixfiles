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
}
