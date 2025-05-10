{ stdenvNoCC, python3, fetchFromGitHub, mkYarnPackage, fetchYarnDeps
, yarnConfigHook, yarnBuildHook, yarnInstallHook, nodejs, fetchzip, fetchpatch,
}:
let
  version = "unstable-2025-05-09";

  src = fetchFromGitHub {
    owner = "inventree";
    repo = "InvenTree";
    rev = "e0acfaa762da0dd7b2822b567202210ca8b7dbd3";
    hash = "sha256-K+cqErDUmgPO7625P3jp7+7BOYEfyJ1nElae6RlJvvI=";
  };

  frontend = stdenvNoCC.mkDerivation {
    name = "inventree-frontend";
    inherit version src;

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${src}/src/frontend/yarn.lock";
      hash = "sha256-KpWuYCrkGN+4UnwV1STEbTL0FWcLZ7Wq8a8ST55OpGM=";
    };

    nativeBuildInputs = [ yarnConfigHook nodejs ];

    patchPhase = ''
      runHook prePatch
      cd src/frontend
      runHook postPatch
    '';

    buildPhase = ''
      echo "Running lingui"
      ./node_modules/.bin/lingui compile --typescript
      echo building lib
      ./node_modules/.bin/tsc --p ./tsconfig.lib.json
      ./node_modules/.bin/vite --config vite.lib.config.ts build
      echo "Running tsc"
      ./node_modules/.bin/tsc
      echo "Running vite"
      ./node_modules/.bin/vite build --emptyOutDir --outDir $out
    '';
  };

in python3.pkgs.buildPythonApplication rec {
  pname = "InvenTree";
  inherit version src;

  format = "other";

  dependencies = with python3.pkgs; [
    coreapi
    cryptography
    distutils
    dj-rest-auth
    django_4
    django-allauth
    django-allauth.optional-dependencies.openid
    django-allauth.optional-dependencies.mfa
    django-allauth.optional-dependencies.socialaccount
    django-cleanup
    django-cors-headers
    django-dbbackup
    django-error-report-2
    django-filter
    django-flags
    django-formtools
    django-ical
    django-js-asset
    django-maintenance-mode
    django-markdownify
    django-money
    django-mptt
    django-redis
    django-oauth-toolkit
    django-otp
    django-q-sentry
    django-q2
    django-redis
    django-sesame
    django-sql-utils
    django-structlog
    django-stdimage
    django-taggit
    django-user-sessions
    django-weasyprint
    djangorestframework
    djangorestframework-simplejwt
    djangorestframework-simplejwt.optional-dependencies.crypto
    django-xforwardedfor-middleware
    drf-spectacular
    dulwich
    feedparser
    gunicorn
    pdf2image
    pillow
    pint
    pip-licenses
    pypdf
    python-barcode
    python-barcode.optional-dependencies.images
    python-dotenv
    pyyaml
    qrcode
    qrcode.optional-dependencies.pil
    rapidfuzz
    sentry-sdk
    tablib
    tablib.optional-dependencies.xls
    tablib.optional-dependencies.xlsx
    tablib.optional-dependencies.yaml
    weasyprint
    whitenoise

    psycopg2
    fido2
  ];

  nativeCheckInputs = with python3.pkgs; [ django-slowtests ];

  #env.INVENTREE_DB_ENGINE = "sqlite3";
  #env.INVENTREE_DB_NAME = "inventree.sqlite3";
  #env.INVENTREE_BACKUP_DIR = "test_inventree_backup";
  #env.INVENTREE_MEDIA_ROOT = "test_inventree_media";
  #env.INVENTREE_STATIC_ROOT = "test_inventree_static";
  #env.INVENTREE_SITE_URL = "http://127.0.0.1:12345";
  #
  #checkPhase = ''
  #  python ./src/backend/InvenTree/manage.py check
  #  python ./src/backend/InvenTree/manage.py test
  #'';

  installPhase = ''
    mkdir -p $out/opt/inventree
    cp -r . $out/opt/inventree

    echo "Installing frontend"

    mkdir -p $out/opt/inventree/src/backend/InvenTree/web/static/web
    cp -r ${frontend}/* $out/opt/inventree/src/backend/InvenTree/web/static/web/
    cp -r ${frontend}/.* $out/opt/inventree/src/backend/InvenTree/web/static/web/
  '';

  passthru = {
    pythonPath = python3.pkgs.makePythonPath dependencies;
    gunicorn = python3.pkgs.gunicorn;
    inherit frontend;
  };
}
