{ python3Packages, fetchFromSourcehut }:

python3Packages.buildPythonApplication {
  pname = "partlint";
  version = "1.2.0";

  src = fetchFromSourcehut {
    owner = "~martijnbraam";
    repo = "partlint";
    rev = "7364f004bd519afa5b0f0a6bd850faff9675f615";
    hash = "sha256-EN88wPeuTu3vZGDIFKXOZxzKg9i7XPQVLSVm9Aq6yi0=";
  };

  propagatedBuildInputs = with python3Packages; [
    sexpdata
    tabulate
    requests
    openpyxl
  ];
}
