{ lib, buildPythonPackage, fetchFromGitHub, poetry-core, setuptools, sentry-sdk,
}:

buildPythonPackage rec {
  pname = "django-q-sentry";
  version = "0.1.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "danielwelch";
    repo = "django-q-sentry";
    rev = "d3a43a90c82734244d5ebf3295652223053f1354";
    hash = "sha256-3C7A+X18c7p19HWD/uPRtAMf29VjmrfXXh2z5PPOREY=";
  };

  build-system = [ poetry-core setuptools ];

  dependencies = [ sentry-sdk ];

  pythonImportsCheck = [ "django_q_sentry" ];

  meta = {
    description = "Bringing Sentry error tracking to Django Q";
    homepage = "https://github.com/danielwelch/django-q-sentry";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
