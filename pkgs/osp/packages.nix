{ python37Packages, gnused }:

let
  fetchPypi = python37Packages.fetchPypi;
  buildPythonPackage = python37Packages.buildPythonPackage;
in rec {
  flask_session = buildPythonPackage rec {
    pname = "Flask-Session";
    version = "0.3.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-B2jiu/Bvlj7BqnEb3nqjLcOf9w+JtJXW22h9iZ6uRCM=";
    };

    propagatedBuildInputs = with python37Packages; [ cachelib flask ];

    doCheck = false;
  };
  flask_security = python37Packages.buildPythonPackage rec {
    pname = "Flask-Security";
    version = "3.0.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-1h2qX1pI+J8w9QVVhyvfWBssZYBGaLAxM0XNe+/yZDI=";
    };

    propagatedBuildInputs = with python37Packages; [
      flask
      pytest
      pytest-runner
      Babel
      flask_wtf
      passlib
      flask_mail
      flask_login
      flask-babelex
      flask_principal
    ];

    doCheck = false;
  };
  pytest-runner = python37Packages.buildPythonPackage rec {
    pname = "pytest-runner";
    version = "5.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-lsfnPq17k+OIxdYUdw0rrmUm79mXdX01Q/4XtVeglCs=";
    };

    propagatedBuildInputs = with python37Packages; [ setuptools_scm ];

    doCheck = false;
  };
  flask-uploads = python37Packages.buildPythonPackage rec {
    pname = "Flask-Uploads";
    version = "0.2.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-U+y9YDNmfVCuArY63ruqM8f8VsCeUpMCWBDPnYQeywI=";
    };

    configurePhase = ''
      sed 's/from werkzeug import secure_filename, FileStorage/from werkzeug.utils import secure_filename\nfrom werkzeug.datastructures import FileStorage/' -i flask_uploads.py
    '';

    doCheck = false;

    propagatedBuildInputs = with python37Packages; [ flask ];

    buildInputs = [ gnused ];
  };
  flask_markdown = python37Packages.buildPythonPackage rec {
    pname = "Flask-Markdown";
    version = "0.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-2MPwJUWzla1SW4Z2CtchosUO+juOYCqNSGofR/aMYlA=";
    };

    propagatedBuildInputs = with python37Packages; [ flask markdown ];

    doCheck = false;
  };
  flask-debugtoolbar = python37Packages.buildPythonPackage rec {
    pname = "Flask-DebugToolbar";
    version = "0.11.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-PE5501Tt4BTmZXxUWlNtT7JzzInj/WtINbAuNG3TqrQ=";
    };

    propagatedBuildInputs = with python37Packages; [ flask blinker ];

    doCheck = false;
  };
  apscheduler = python37Packages.buildPythonPackage rec {
    pname = "APScheduler";
    version = "3.6.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-O7Uinu1vu9r8E86WJxKuZuF1qiFMab7TWga//PDF4kQ=";
    };

    propagatedBuildInputs = with python37Packages; [
      setuptools_scm
      six
      pytz
      tzlocal
    ];

    doCheck = false;
  };

}
