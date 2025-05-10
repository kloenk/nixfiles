{ lib, buildPythonPackage, fetchFromGitHub, setuptools, wheel, django, }:

buildPythonPackage rec {
  pname = "django-flags";
  version = "5.0.13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cfpb";
    repo = "django-flags";
    rev = version;
    hash = "sha256-WPMfFYoP6WaVzZmVtqAz4LlY761aCRyPhd5npc8bOOI=";
  };

  build-system = [ setuptools wheel ];

  dependencies = [ django ];

  pythonImportsCheck = [ "flags" ];

  meta = {
    description = "Feature flags for Django projects";
    homepage = "https://github.com/cfpb/django-flags";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ ];
  };
}
