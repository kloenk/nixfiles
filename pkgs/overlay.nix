inputs: final: prev:
let inherit (final) callPackage;
in {
  collectd-wireguard = callPackage ./collectd-wireguard { };
  jblock = callPackage ./jblock { };
  deploy_secrets = callPackage ./deploy_secrets { };
  pass-nix = callPackage ./pass-nix { };
  wallpapers = callPackage ./wallpapers { };
  fabric-server = callPackage ./fabric-server { };
  pam_nfc = callPackage ./pam_nfc { };

  libnfc0 = callPackage ./libnfc { };

  owncast = callPackage (inputs.nixpkgs_owncast + "/pkgs/servers/owncast/default.nix") { };

  redshift = prev.redshift.overrideAttrs (oldAttrs: rec {
    src = final.fetchFromGitHub {
      owner = "minus7";
      repo = "redshift";
      rev = "eecbfedac48f827e96ad5e151de8f41f6cd3af66";
      sha256 = "0rs9bxxrw4wscf4a8yl776a8g880m5gcm75q06yx2cn3lw2b7v22";
    };
  });

  spidermonkey_38 = null;

  #mixnix = callPackage (inputs.mixnix + "/nix/mix2nix.nix") { };
  #pleroma = callPackage ./pleroma { };
  pleroma = callPackage (inputs.petabyte + "/pkgs/pleroma") { };

  #let source = callPackage ./sourcegraph { }; in inherit (source) ;
  inherit (callPackage ./sourcegraph { }) sourcegraph_go sourcegraph_web;

  inherit (final.callPackage ./firefox { })
    firefoxPolicies firefox-policies-wrapped;

  nix-serve = prev.nix-serve.overrideAttrs (oldAttrs: rec {
    meta = oldAttrs.meta // { platforms = final.lib.platforms.linux; };
  });
  jitsiexporter = callPackage ./jitsiexporter { };

  matrix-to = callPackage ./matrix-to { };

  rustc_nightly = prev.rustc.overrideAttrs (oldAttrs: {
    configureFlags = map (flag:
      if flag == "--release-channel=stable" then
        "--release-channel=nightly"
      else
        flag) oldAttrs.configureFlags;
  });
  rust-bindgen = prev.rust-bindgen.override {
    clang = final.clang_11;
    llvmPackages = final.llvmPackages_11;
  };

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

  wordpressPlugins = callPackage ./wordpress/plugins.nix { };
  wordpressThemes = callPackage ./wordpress/themes.nix { };

  moodlePackages = {
    bbb = final.moodle-utils.buildMoodlePlugin {
      name = "bigbluebuttonbn";
      src = final.fetchzip {
        name = "bbb-moodle-plugin";
        url =
          "https://moodle.org/plugins/download.php/24237/mod_bigbluebuttonbn_moodle311_2019101008.zip";
        sha256 = "sha256-86MiwOs8dDCCRx1Kj2PyJ64xAshgkGLY7+xiSfBZVJg";
        extraPostFetch = ''
          echo fix perm: $out
          chmod a-w -R $out
        '';
      };
      pluginType = "mod";
    };
    tiles = final.moodle-utils.buildMoodlePlugin {
      name = "tiles";
      src = final.fetchzip {
        name = "tiles";
        url =
          "https://moodle.org/plugins/download.php/23359/format_tiles_moodle310_2020080613.zip";
        sha256 = "1vya5j7nhyb1xmkp3ia26zb7k2w0z8axpqr2scgbd2kmb8lqgccq";
        extraPostFetch = ''
          echo fix perm: $out
          chmod a-w -R $out
        '';
      };
      pluginType = "course";
    };
    sharing_cart = final.moodle-utils.buildMoodlePlugin {
      name = "sharing_cart";
      src = final.fetchzip {
        name = "sharing_cart";
        url =
          "https://moodle.org/plugins/download.php/23686/block_sharing_cart_moodle310_2021031300.zip";
        sha256 = "sha256-AwxPMC+f842roMYpihBrobR4inBVAvj3wQX2SancMLw";
        extraPostFetch = ''
          echo fix perm: $out
          chmod a-w -R $out
        '';
      };
      pluginType = "block";
    };
    scheduler = final.moodle-utils.buildMoodlePlugin {
      name = "scheduler";
      src = final.fetchzip {
        name = "scheduler";
        url =
          "https://moodle.org/plugins/download.php/20738/mod_scheduler_moodle39_2019120200.zip";
        sha256 = "0n5qbqcb3j631j6q7fw0anffp7hgc2c7mg8z3i5z6fpi1pc20sjg";
        extraPostFetch = ''
          echo fix perm: $out
          chmod a-w -R $out
        '';
      };
      pluginType = "mod";
    };
  };
}
