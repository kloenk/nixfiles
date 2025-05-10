{ lib, buildPythonPackage, fetchFromGitHub, setuptools, wheel, django_4, pytz,
}:

buildPythonPackage rec {
  pname = "django-dbbackup";
  version = "4.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-dbbackup";
    rev = version;
    hash = "sha256-GD+f9mbImGPQ6MOUK3ftHqiGv7TT39jNQsFvd0dnnWU=";
  };

  build-system = [ setuptools wheel ];

  dependencies = [ django_4 pytz ];

  pythonImportsCheck = [ "dbbackup" ];

  meta = {
    description =
      "Management commands to help backup and restore your project database and media files";
    homepage = "https://github.com/jazzband/django-dbbackup";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "django-dbbackup";
  };
}
