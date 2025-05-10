{ lib, buildPythonPackage, fetchFromGitHub, setuptools, wheel, django, }:

buildPythonPackage rec {
  pname = "django-xforwardedfor-middleware";
  version = "2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "allo-";
    repo = "django-xforwardedfor-middleware";
    rev = "v${version}";
    hash = "sha256-dDXSb17kXOSeIgY6wid1QFHhUjrapasWgCEb/El51eA=";
  };

  build-system = [ setuptools wheel ];

  dependencies = [ django ];

  pythonImportsCheck = [ "x_forwarded_for" ];

  meta = {
    description =
      "Use the X-Forwarded-For header to get the real ip of a request";
    homepage = "https://github.com/allo-/django-xforwardedfor-middleware";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ ];
  };
}
