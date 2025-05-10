{ lib, buildPythonPackage, fetchFromGitHub, setuptools, bleach, django, markdown
, }:

buildPythonPackage rec {
  pname = "django-markdownify";
  version = "0.9.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "erwinmatijsen";
    repo = "django-markdownify";
    rev = version;
    hash = "sha256-KYU8p8NRD4EIS/KhOk9nvmXCf0RWEc+IFZ57YtsDSWE=";
  };

  build-system = [ setuptools ];

  dependencies = [ bleach django markdown ];

  pythonImportsCheck = [ "markdownify" ];

  meta = {
    description = "Markdown template filter for Django";
    homepage = "https://github.com/erwinmatijsen/django-markdownify";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
