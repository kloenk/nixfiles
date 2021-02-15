{ buildGoModule, fetchgit, ... }:

buildGoModule rec {
  pname = "jitsiexporter";
  version = "0.2.18";

  src = fetchgit {
    url = "https://git.xsfx.dev/prometheus/jitsiexporter";
    rev = "v${version}";
    sha256 = "1cf46wp96d9dwlwlffcgbcr0v3xxxfdv6il0zqkm2i7cfsfw0skf";
  };

  vendorSha256 = null;
}
