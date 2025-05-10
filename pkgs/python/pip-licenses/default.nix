{ lib, buildPythonPackage, fetchFromGitHub, setuptools, setuptools-scm, wheel
, prettytable, tomli, autopep8, black, docutils, isort, mypy, pip-tools
, pypandoc, pytest-cov, pytest-pycodestyle, pytest-runner, tomli-w, twine, }:

buildPythonPackage rec {
  pname = "pip-licenses";
  version = "5.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "raimon49";
    repo = "pip-licenses";
    rev = "v-${version}";
    hash = "sha256-6xw6BCuXSzNcwkpHaEFC5UPpubPUwhx/pg6vZq2er7A=";
  };

  build-system = [ setuptools setuptools-scm wheel ];

  dependencies = [ prettytable tomli ];

  optional-dependencies = {
    dev = [
      autopep8
      black
      docutils
      isort
      mypy
      pip-tools
      pypandoc
      pytest-cov
      pytest-pycodestyle
      pytest-runner
      tomli-w
      twine
      wheel
    ];
  };

  pythonImportsCheck = [ "piplicenses" ];

  meta = {
    description = "Dump the license list of packages installed with pip";
    homepage = "https://github.com/raimon49/pip-licenses";
    changelog =
      "https://github.com/raimon49/pip-licenses/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
