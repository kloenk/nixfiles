{ stdenv, python37Packages, fetchFromGitLab, gnused, python37, callPackage }:

let osp-packages = callPackage ./packages.nix { };
in stdenv.mkDerivation rec {
  pname = "osp";
  version = "0.7.9";

  src = fetchFromGitLab {
    owner = "Deamos";
    repo = "flask-nginx-rtmp-manager";
    rev = version;
    sha256 = "sha256-XOz1kKEUHpAx/FSHldUPomR+Fa2SfsLEq24JMsTnSqw=";
  };

  /* penv = python37.buildEnv.withPackages (e: with e; [
         flask_migrate
         flask_script
         flask_session
         flask_security
         flask-uploads
         flask_markdown
         flask-debugtoolbar
         flask-cors
         flask-socketio
         flask-limiter
         redis
         apscheduler
         gevent
         email_validator
         werkzeug
         authlib
     ]);
  */
  penv = let
    flask-restplus = python37Packages.flask-restplus.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ gnused ];
      configurePhase = ''
        sed 's/from werkzeug import cached_property/from werkzeug.utils import cached_property/' -i flask_restplus/fields.py
        sed 's/from werkzeug import cached_property/from werkzeug.utils import cached_property/' -i flask_restplus/api.py
      '';
    });
  in python37.buildEnv.override {
    extraLibs = with python37Packages;
      with osp-packages; [
        flask_migrate
        flask_script
        flask_session
        flask_security
        flask-uploads
        flask_markdown
        flask-debugtoolbar
        flask-cors
        flask-socketio
        flask-limiter
        flask-restplus
        redis
        apscheduler
        gevent
        email_validator
        werkzeug
        authlib
        xmltodict
        psutil
        pillow
        pilkit
        GitPython
        psycopg2
        gunicorn
      ];
  };

  installPhase = ''
    mkdir $out
    mkdir $out/bin
    cp -r blueprints cache classes conf db docs functions globals logs static templates "$out/"

    cp *.py "$out/"
    echo "#!${penv}/bin/python3.7" > "$out/manage.py"
    cat manage.py >> "$out/manage.py"
    chmod +x "$out/manage.py"

    ln -s "$out/manage.py" "$out/bin/manage"
    ln -s "/etc/osp/config.py" "$out/conf/config.py"

    cp setup/ejabberd/auth_osp.py "$out/bin/auth_osp.py"
    chmod +x "$out/bin/auth_osp.py"
  '';
}
