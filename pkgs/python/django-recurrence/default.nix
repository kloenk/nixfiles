{ lib, buildPythonPackage, fetchFromGitHub, pdm-backend, django, flake8, pytest
, pytest-cov, pytest-django, pytest-sugar, python-dateutil, sphinx
, sphinx-rtd-theme, tox, }:

buildPythonPackage rec {
  pname = "django-recurrence";
  version = "1.12.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-recurrence";
    rev = version;
    hash = "sha256-Q33zyMa1wI13RNLxynGAJHlagahpnFHCmZbHp0aPC/w=";
  };

  build-system = [ pdm-backend ];

  dependencies = [
    django
    flake8
    pytest
    pytest-cov
    pytest-django
    pytest-sugar
    python-dateutil
    sphinx
    sphinx-rtd-theme
    tox
  ];

  pythonRelaxDeps = true;

  pythonImportsCheck = [ "recurrence" ];

  meta = {
    description = "Utility for working with recurring dates in Django";
    homepage = "https://github.com/django-recurrence/django-recurrence";
    changelog =
      "https://github.com/django-recurrence/django-recurrence/blob/${src.rev}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
}
