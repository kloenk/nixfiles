{ lib, buildPythonPackage, fetchFromGitHub, setuptools, asgiref, django
, django-ipware, structlog, celery, django-extensions, }:

buildPythonPackage rec {
  pname = "django-structlog";
  version = "9.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jrobichaud";
    repo = "django-structlog";
    rev = version;
    hash = "sha256-SEigOdlXZtfLAgRgGkv/eDNDAiiHd7YthRJ/H6e1v5U=";
  };

  build-system = [ setuptools ];

  dependencies = [ asgiref django django-ipware structlog ];

  optional-dependencies = {
    celery = [ celery ];
    commands = [ django-extensions ];
  };

  pythonImportsCheck = [ "django_structlog" ];

  meta = {
    description = "";
    homepage = "https://github.com/jrobichaud/django-structlog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
