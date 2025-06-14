{ lib, stdenv, linuxPackages_latest, bash,

rustPlatform, llvmPackages, buildPackages, linuxManualConfig, }:

lib.makeOverridable ({ baseKernel ? linuxPackages_latest.kernel
  , defconfig ? "defconfig",
  # undo some options that defconfig does
  undoDefConfig ? true,
  # Add extra kernel config snippets (e.g. `kvm_guest.config`)
  kernelConfigTargets ? null, hetznerKernel ? false, drm ? true
  , moduleSupport ? true, signeModules ? moduleSupport, localVersion ? true
  , extraLocalVersion ? [ ], structuredExtraConfig ? { }, extraMakeFlags ? [ ]
  , kernelPatches ? [ ], kernelArch ? stdenv.hostPlatform.linuxArch, ... }:
  let
    kernel = baseKernel.override { inherit stdenv kernelPatches; };

    kernelConfigTargets' = if kernelConfigTargets != null then
      kernelConfigTargets
    else
      (lib.optional hetznerKernel "kvm_guest.config");

    configName = lib.concatStringsSep "-"
      ((lib.optional hetznerKernel "hetzner") ++ extraLocalVersion);

    makeFlags = (if stdenv.cc.isClang then [
      "LLVM=1"
      "NM=${llvmPackages.libllvm}/bin/llvm-nm"
      "STRIP=${llvmPackages.libllvm}/bin/llvm-strip"
      "OBJCOPY=${llvmPackages.libllvm}/bin/llvm-objcopy"
      "READELF=${llvmPackages.libllvm}/bin/llvm-readelf"
      "LLVM_AS=${llvmPackages.libllvm}/bin/llvm-as"
      "LLVM_LINK=${llvmPackages.libllvm}/bin/llvm-link"
      #"KCFLAGS=\"-isystem ${llvmPackages.clang}/resource-root/include\""
      "CC=${llvmPackages.clang-unwrapped}/bin/clang"
      "HOSTCC=${llvmPackages.clang}/bin/clang"
      "LD=${llvmPackages.bintools-unwrapped}/bin/ld.lld"
      "HOSTLD=${llvmPackages.bintools}/bin/ld.lld"
      "AR=${llvmPackages.bintools-unwrapped}/bin/ar"
      "HOSTAR=${llvmPackages.bintools}/bin/ar"
    ] else [
      "CC=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
      "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
      "HOSTLD=${buildPackages.stdenv.cc.bintools}/bin/${buildPackages.stdenv.cc.targetPrefix}ld"
    ]) ++ extraMakeFlags;

    structuredConfigFromPatches = map ({ extraStructuredConfig ? { }, ... }: {
      settings = extraStructuredConfig;
    }) kernelPatches;

    intermediateNixConfig =
      configfile.moduleStructuredConfig.intermediateNixConfig
      + stdenv.hostPlatform.linux-kernel.extraConfig or "";

    # appends kernel patches extraConfig
    kernelConfigFun = baseConfigStr:
      let
        configFromPatches =
          map ({ extraConfig ? "", ... }: extraConfig) kernelPatches;
      in lib.concatStringsSep "\n" ([ baseConfigStr ] ++ configFromPatches);

    withRust =
      ((configfile.moduleStructuredConfig.settings.RUST or { }).tristate or null)
      == "y";

    flattenKConf = nested:
      lib.mapAttrs (name: values:
        if lib.length values == 1 then
          lib.head values
        else
          throw "duplicate kernel configuration option: ${name}")
      (lib.zipAttrs (lib.attrValues nested));

    importConfig = config: import config { inherit lib flattenKConf; };

    configfile = stdenv.mkDerivation {
      inherit kernelArch makeFlags;
      pname = "gwp-${configName}-linux-config";
      inherit (kernel) src version patches postPatch;

      NOMODULES = !moduleSupport;
      kernelConfig = kernelConfigFun intermediateNixConfig;
      passAsFile = [ "kernelConfig" ];

      depsBuildBuild = [ buildPackages.stdenv.cc ];
      nativeBuildInputs = kernel.nativeBuildInputs ++ [ bash ];

      RUST_LIB_SRC = lib.optionalString withRust rustPlatform.rustLibSrc;

      platformName = stdenv.hostPlatform.linux-kernel.name;
      kernelBaseConfig = if defconfig != null then
        defconfig
      else
        stdenv.hostPlatform.linux-kernel.baseConfig;

      preUnpack = kernel.preUnpack or "";

      buildPhase = let
        moduleOptionTo = name: value:
          {
            "bool" = if value then "--enable ${name}" else "--disable ${name}";
            "int" = "--set-val ${name} ${toString value}";
            "string" = "--set-str ${name} ${value}";
            "null" = "--undefine ${name}";
            "set" = if (value.freeform or null) != null then
              moduleOptionTo name value.freeform
            else
              {
                "null" = "--undefine ${name}";
                "m" = if moduleSupport then
                  "--module ${name}"
                else
                  "--enable ${name}";
                "y" = "--enable ${name}";
                "n" = "--disable ${name}";
              }.${if value.tristate != null then value.tristate else "null"};
          }.${builtins.typeOf value};

        structuredUndoConfig = lib.optionalAttrs undoDefConfig import
          (./. + "/undef-${stdenv.hostPlatform.system}.nix") { inherit lib; };
      in ''
        export buildRoot="''${buildRoot:-build}"

        # Get a basic config file
        echo "creating defconfig"
        make $makeFlags "''${makeFlagsArray[@]}" \
          -C . O="$buildRoot" $kernelBaseConfig \
          ARCH=$kernelArch CROSS_COMPILE=${stdenv.cc.targetPrefix}

        echo "removing unwanted defconfig options"
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: val: ''
          bash ./scripts/config --file "$buildRoot/.config" ${
            moduleOptionTo name val
          }
        '') structuredUndoConfig)}

        echo "applying config targets"
        ${lib.concatStringsSep "\n" (map (config: ''
          echo "make ${config}"
          make $makeFlags "''${makeFlagsArray[@]}" \
            -C . O="$buildRoot" ${config} \
            ARCH=$kernelArch CROSS_COMPILE=${stdenv.cc.targetPrefix}
        '') kernelConfigTargets')}

        echo "applying config"
        bash ${./mkconfig.sh} "$buildRoot/.config" "$kernelConfigPath" set

        echo "make olddefconfig"
        make $makeFlags "''${makeFlagsArray[@]}" \
          -C . O="$buildRoot" olddefconfig \
          ARCH=$kernelArch CROSS_COMPILE=${stdenv.cc.targetPrefix}

        echo "checking config"
        bash ${./mkconfig.sh} "$buildRoot/.config" "$kernelConfigPath" check
      '';

      installPhase = "mv $buildRoot/.config $out";

      enableParallelBuilding = true;

      passthru = rec {
        inherit (kernel.configfile.passthru) module;

        moduleStructuredConfig = (lib.evalModules {
          modules = [ module ] ++ [{
            settings = importConfig ./config-common.nix;
            _file = "nix/kernels/config-common.nix";
          }] ++ lib.optionals hetznerKernel [{
            settings = importConfig ./config-hetzner.nix;
            _file = "nix/kernels/config-host.nix";
          }] ++ [{
            settings = with lib.kernel; {
              MODULE = if moduleSupport then yes else no;
            };
            _file = "moduleSupport";
          }] ++ lib.optionals signeModules [{
            settings = with lib.kernel; {
              MODULE_SIG = yes;
              MODULE_SIG_SHA384 = yes;
              MODULE_SIG_ALL = yes;
              MODULE_SIG_KEY_TYPE_ECDSA = yes;
            };
            _file = "signedModules";
          }] ++ lib.optionals localVersion [{
            settings = {
              LOCALVERSION = lib.kernel.freeform
                (lib.optionalString (configName != "") "+${configName}");
            };
            _file = "localVersion";
          }] ++ lib.optionals drm [{
            settings = {
              DRM = lib.kernel.yes;
              FB = lib.kernel.yes;
            };
            _file = "drm";
          }] ++ [{
            settings = structuredExtraConfig;
            _file = "structuredExtraConfig";
          }] ++ structuredConfigFromPatches;
        }).config;

        structuredConfig = moduleStructuredConfig.settings;

        kernelConfigTargets = kernelConfigTargets';
      };
    };

    manualConfig = linuxManualConfig.override { inherit stdenv; };
  in manualConfig {
    inherit (kernel) src version;
    pname = if (localVersion && configName != "") then
      "${kernel.pname}+${configName}"
    else
      kernel.pname;
    modDirVersion = if (localVersion && configName != "") then
      "${kernel.modDirVersion}+${configName}"
    else
      kernel.modDirVersion;

    kernelPatches = kernel.kernelPatches ++ [{
      name = "kloenk-genkey";
      patch = ./x509-genkey.patch;
    }] ++ kernelPatches;

    inherit configfile;
    config = lib.mapAttrs' (name: value: {
      name = "CONFIG_${name}";
      value = if (value.freeform or null) != null then
        value.freeform
      else
        value.tristate;
    }) configfile.moduleStructuredConfig.settings;

    extraMakeFlags = makeFlags;

  })
