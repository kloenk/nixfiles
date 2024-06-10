{ python3, fetchFromGitHub, mkYarnPackage, fetchzip }:
let
  version = "0.15.3";

  src = fetchFromGitHub {
    owner = "inventree";
    repo = "InvenTree";
    rev = version;
    hash = "sha256-Nm385UHOCtSGlaAG35X67pjFctDO5cB6cU3A2Cgqask=";
  };

  /* frontend = mkYarnPackage {
       inherit version;
       src = "${src}/src/frontend";

       packageJSON = ./package.json;
       yarnLock = ./yarn.lock;
       yarnNix = ./yarn.nix;

       configurePhase = ''
         #ln -s $node_modules node_modules
         cp -r $node_modules node_modules
       '';

       buildPhase = ''
         ls node_modules
         echo running tsc
         #./node_modules/.bin/tsc
         echo running vite
         ./node_modules/.bin/vite build --outDir $out
       '';

       doDist = false;
     };
  */
  frontend = fetchzip {
    name = "inventree-frontend";
    url =
      "https://github.com/inventree/InvenTree/releases/download/${version}/frontend-build.zip";
    hash = "sha256-Ln6VhCwFw5LLA/80iREx4yq0ONaclgG8tC1GoT71u0g=";
    stripRoot = false;
  };

in python3.pkgs.buildPythonApplication rec {
  pname = "InvenTree";
  inherit version src;

  patches = [ ./i18n_dir.diff ];

  format = "other";

  propagatedBuildInputs = with python3.pkgs; [
    asgiref
    async-timeout
    attrs
    babel
    bleach
    brotli
    certifi
    cffi
    charset-normalizer
    coreapi
    coreschema
    cryptography
    cssselect2
    defusedxml
    diff-match-patch
    dj-rest-auth
    django
    django-allauth
    django-allauth-2fa
    django-cleanup
    django-cors-headers
    django-crispy-forms
    django-crispy-bootstrap4
    django-dbbackup
    django-error-report-2
    django-filter
    django-flags
    django-formtools
    django-ical
    django-import-export
    django-js-asset
    django-maintenance-mode
    django-markdownify
    django-money
    django-mptt
    django-otp
    django-picklefield
    django-q-sentry
    django-q2
    django-recurrence
    django-redis
    django-sesame
    django-sql-utils
    django-sslserver
    django-stdimage
    django-taggit
    django-user-sessions
    django-weasyprint
    django-xforwardedfor-middleware
    django-slowtests
    djangorestframework
    djangorestframework-simplejwt
    drf-spectacular
    dulwich
    et-xmlfile
    feedparser
    fonttools
    gunicorn
    html5lib
    icalendar
    idna
    importlib-metadata
    inflection
    itypes
    jinja2
    jsonschema
    jsonschema-specifications
    markdown
    markuppy
    markupsafe
    oauthlib
    odfpy
    openpyxl
    packaging
    pdf2image
    pillow
    pint
    py-moneyed
    pycparser
    pydyf
    pyjwt
    pyphen
    pypng
    python-barcode
    python-dateutil
    python-dotenv
    python-fsutil
    python3-openid
    pytz
    pyyaml
    qrcode
    rapidfuzz
    redis
    referencing
    regex
    requests
    requests-oauthlib
    rpds-py
    sentry-sdk
    sgmllib3k
    six
    sqlparse
    tablib
    tinycss2
    typing-extensions
    uritemplate
    urllib3
    weasyprint
    webencodings
    xlrd
    xlwt
    zipp
    zopfli
    whitenoise
    psycopg2
  ];

  installPhase = ''
    mkdir -p $out/opt/inventree
    cp -r . $out/opt/inventree

    echo "Installing frontend"

    mkdir -p $out/opt/inventree/src/backend/InvenTree/web/static/web
    cp -r ${frontend}/* $out/opt/inventree/src/backend/InvenTree/web/static/web/
  '';

  passthru = {
    pythonPath = python3.pkgs.makePythonPath propagatedBuildInputs;
    gunicorn = python3.pkgs.gunicorn;
    inherit frontend;
  };
}
