{ lib, stdenvNoCC, fetchFromGitHub, php, fetchYarnDeps, nodejs, yarnConfigHook
, yarnBuildHook, yarnInstallHook, envLocalPath ? "/var/lib/part-db/env.local"
, cachePath ? "/var/cache/part-db/", logPath ? "/var/log/part-db/"
, uploadsPath ? "/var/lib/part-db/uploads", mediaPath ? "/var/lib/part-db/media"
}:
let
  phpExt =
    php.withExtensions ({ all, enabled }: enabled ++ (with all; [ xsl ]));

in stdenvNoCC.mkDerivation (finalAttrs:
  let
    src = fetchFromGitHub {
      owner = "Part-DB";
      repo = "Part-DB-server";
      tag = "v${finalAttrs.version}";
      hash = finalAttrs.srcHash;
    };

    phpSrc = phpExt.buildComposerProject ({
      inherit (finalAttrs) pname version;
      inherit src;

      php = phpExt;

      composerNoDev = true;
      composerNoPlugins = false;
      composerNoScripts = true;
      composerStrictValidation = false;
      vendorHash = finalAttrs.phpVendorHash;

      postInstall = ''
        mv "$out/share/php/part-db/"* "$out/"
        mv "$out/share/php/part-db/".* "$out/"
        cd "$out/"
        php -d memory_limit=256M bin/console cache:warmup
      '';
    });
  in {
    pname = "part-db";
    version = "1.17.0";
    src = phpSrc;

    srcHash = "sha256-3cZ7whrYXmX96lLromTI6xYuHBh+c47BuviNbB65yus=";
    phpVendorHash = "sha256-4AxsGcJm6UbGFDuTIsV4pwmMAOpmGYQm1x1DA6EblzY=";
    yarnOfflineHash = "sha256-tXDSuP40sihGVh0o+29aQYnK2OXYiFOqJWHPTdADVyA=";

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = finalAttrs.src + "/yarn.lock";
      hash = finalAttrs.yarnOfflineHash;
    };

    nativeBuildInputs = [ yarnConfigHook yarnBuildHook nodejs ];

    installPhase = ''
      rm -r node_modules
      mkdir $out
      mv * .* "$out/"

      rm -rf $out/var/{cache,log}
      ln -s ${envLocalPath} $out/.env.local
      rm -rf $out/uploads $out/public/media
      ln -sf ${uploadsPath} $out/uploads
      ln -sf ${mediaPath} $out/public/media
      ln -s ${logPath} $out/var/log
      ln -s ${cachePath} $out/var/cache
    '';

    meta = {
      description =
        "Open source inventory management system for your electronic components";
      homepage = "https://docs.part-db.de/";
      changelog =
        "https://github.com/Part-DB/Part-DB-server/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.agpl3Plus;
      maintainers = with lib.maintainers; [ felbinger kloenk ];
      platforms = lib.platforms.linux;
    };
  })
