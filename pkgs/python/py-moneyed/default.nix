{ lib, buildPythonPackage, fetchFromGitHub, setuptools, wheel, babel
, typing-extensions, }:

buildPythonPackage rec {
  pname = "py-moneyed";
  version = "3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "py-moneyed";
    repo = "py-moneyed";
    rev = "v${version}";
    hash = "sha256-k0ZbLwog6TYxKDLZV7eH1Br8buMPfpOkgp+pMN/qdB8=";
  };

  build-system = [ setuptools wheel ];

  dependencies = [ babel typing-extensions ];

  pythonImportsCheck = [ "moneyed" ];

  meta = {
    description =
      "Provides Currency and Money classes for use in your Python code";
    homepage = "http://github.com/py-moneyed/py-moneyed";
    changelog =
      "https://github.com/py-moneyed/py-moneyed/blob/${src.rev}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
}
