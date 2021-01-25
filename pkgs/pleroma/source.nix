
{ fetchFromGitLab }:

rec {
  version = "2.2.2";
  src = fetchFromGitLab {
    domain = "git.pleroma.social";
    owner = "pleroma";
    repo = "pleroma";
    rev = "v2.2.2";
    sha256 = "0c2na9yy1lkqdgj4ns586b499ka06m0rbxj75m5j99888av5sifm";
  };
}

