{ lib, buildPythonPackage, fetchFromGitHub, setuptools, setuptools-scm, wheel
, django, pillow, gettext, }:

buildPythonPackage rec {
  pname = "django-stdimage";
  version = "6.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "codingjoe";
    repo = "django-stdimage";
    rev = version;
    hash = "sha256-uwVU3Huc5fitAweShJjcMW//GBeIpJcxqKKLGo/EdIs=";
  };

  build-system = [ setuptools setuptools-scm wheel ];

  dependencies = [ django pillow ];

  nativeBuildInputs = [ gettext ];

  preBuild = ''
    echo "bla bla"
    echo $PATH
  '';

  pythonImportsCheck = [ "stdimage" ];

  meta = {
    description = "";
    homepage = "https://github.com/codingjoe/django-stdimage";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
