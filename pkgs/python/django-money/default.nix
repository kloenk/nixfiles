{ lib, buildPythonPackage, fetchFromGitHub, setuptools, wheel, django
, py-moneyed, }:

buildPythonPackage rec {
  pname = "django-money";
  version = "3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "django-money";
    repo = "django-money";
    rev = version;
    hash = "sha256-eL26NsreUqtMJ26TmvmB53EJI4Sjs7qjFDnnt4N0vdI=";
  };

  build-system = [ setuptools wheel ];

  dependencies = [ django py-moneyed ];

  pythonImportsCheck = [ "djmoney" ];

  meta = {
    description = "Money fields for Django forms and models";
    homepage = "https://github.com/django-money/django-money";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
}
