{ lib, buildPythonPackage, fetchFromGitHub, setuptools, wheel, certifi, urllib3,
}:

buildPythonPackage rec {
  pname = "sentry-sdk";
  version = "2.26.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "sentry-python";
    rev = version;
    hash = "sha256-Wl8yq2X9GuPcqaS93hkKXs2cDzz282Xceaai4NjbVZY=";
    fetchSubmodules = true;
  };

  build-system = [ setuptools wheel ];

  dependencies = [ certifi urllib3 ];

  pythonImportsCheck = [ "sentry_sdk" ];

  meta = {
    description = "The official Python SDK for Sentry.io";
    homepage = "https://github.com/getsentry/sentry-python";
    changelog =
      "https://github.com/getsentry/sentry-python/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
