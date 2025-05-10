{ lib, buildPythonPackage, fetchFromGitHub, setuptools, setuptools-scm, wheel
, django, django-recurrence, icalendar, }:

buildPythonPackage rec {
  pname = "django-ical";
  version = "1.9.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-ical";
    rev = version;
    hash = "sha256-DUe0loayGcUS7MTyLn+g0KBxbIY7VsaoQNHGSMbMI3U=";
  };

  build-system = [ setuptools setuptools-scm wheel ];

  dependencies = [ django django-recurrence icalendar ];

  pythonImportsCheck = [ "django_ical" ];

  meta = {
    description =
      "ICal feeds for Django based on Django's syndication feed framework";
    homepage = "https://github.com/jazzband/django-ical";
    changelog =
      "https://github.com/jazzband/django-ical/blob/${src.rev}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
