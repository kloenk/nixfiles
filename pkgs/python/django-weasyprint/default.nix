{ lib, buildPythonPackage, fetchFromGitHub, setuptools, django, weasyprint, }:

buildPythonPackage rec {
  pname = "django-weasyprint";
  version = "2.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fdemmer";
    repo = "django-weasyprint";
    rev = "v${version}";
    hash = "sha256-eSh1p+5MyYb6GIEgSdlFxPzVCenlkwSCTkTzgKjezIg=";
  };

  build-system = [ setuptools ];

  dependencies = [ django weasyprint ];

  pythonImportsCheck = [ "django_weasyprint" ];

  meta = {
    description =
      "A Django class-based view generating PDF resposes using WeasyPrint";
    homepage = "https://github.com/fdemmer/django-weasyprint";
    changelog =
      "https://github.com/fdemmer/django-weasyprint/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
