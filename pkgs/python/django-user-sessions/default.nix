{ lib, buildPythonPackage, fetchFromGitHub, setuptools, setuptools-scm, wheel
, django, }:

buildPythonPackage rec {
  pname = "django-user-sessions";
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-user-sessions";
    rev = version;
    hash = "sha256-Wexy6G2pZ8LTnqtJkBZIePV7qhQW8gu/mKiQfZtgf/o=";
  };

  build-system = [ setuptools setuptools-scm wheel ];

  dependencies = [ django ];

  pythonImportsCheck = [ "user_sessions" ];

  meta = {
    description =
      "Extend Django sessions with a foreign key back to the user, allowing enumerating all user's sessions";
    homepage = "http://github.com/jazzband/django-user-sessions";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
