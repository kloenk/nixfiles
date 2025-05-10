{ lib, buildPythonPackage, fetchFromGitHub, setuptools, wheel, django_4, }:

buildPythonPackage rec {
  pname = "django-slowtests";
  version = "1.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "realpython";
    repo = "django-slow-tests";
    rev = version;
    hash = "sha256-gW9AZiMpXJp1m2X1cbm6GdZ9cH+TFqjNLQJFmsvGjB0=";
  };

  build-system = [ setuptools wheel ];

  dependencies = [ django_4 ];

  pythonImportsCheck = [ "django_slowtests" ];

  meta = {
    description = "Locate your slowest tests";
    homepage = "https://github.com/realpython/django-slow-tests";
    changelog =
      "https://github.com/realpython/django-slow-tests/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
