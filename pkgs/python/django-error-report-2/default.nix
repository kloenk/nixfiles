{ lib, buildPythonPackage, fetchFromGitHub, setuptools, wheel, django, }:

buildPythonPackage rec {
  pname = "django-error-report-2";
  version = "0.4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "matmair";
    repo = "django-error-report-2";
    rev = version;
    hash = "sha256-ZCaslqgruJxM8345/jSlZGruM+27H9hvwL0wtPkUzc0=";
  };

  build-system = [ setuptools wheel ];

  dependencies = [ django ];

  pythonImportsCheck = [ "error_report" ];

  meta = {
    description = "Log/View Django server errors";
    homepage = "https://github.com/matmair/django-error-report-2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
