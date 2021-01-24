{ callPackage }:

let
  buildTheme = { name ? builtins.baseNameOf url, url, sha256, ...  }@extraArgs: callPackage ({fetchurl, stdenv, unzip }: stdenv.mkDerivation {
    inherit name;
    src = fetchurl {
      inherit url sha256;
    };
    buildInputs = [ unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  } // extraArgs) {};
in {
  twentyTwelf = buildTheme {
    url = "https://downloads.wordpress.org/theme/twentytwelve.3.3.zip";
    sha256 = "9a57d135b166efe12b2e8ef45f0bfac1c5ef9b59cfaab447e0d10a5eff9aaaad";
  };
  twentyFourteen = buildTheme {
    url = "https://downloads.wordpress.org/theme/twentyfourteen.3.0.zip";
    sha256 = "dd17fdff5322b30492aa1bda8f01eef5b45d5165c58944a719eb7483ceccbcec";
  };
  twentyFifteen = buildTheme {
    url = "https://downloads.wordpress.org/theme/twentyfifteen.2.8.zip";
    sha256 = "84696f84b9b5b3671596fec82033eb3c44703b9aa59c67c134543eb43720edf5";
  };
  twentySixteen = buildTheme {
    url = "https://downloads.wordpress.org/theme/twentysixteen.2.3.zip";
    sha256 = "c3db11052781516e35c27927bff5b0a85cc00ced0674a2590b79ea5f7cbe3e03";
  };
  twentySeventeen = buildTheme {
    url = "https://downloads.wordpress.org/theme/twentyseventeen.2.5.zip";
    sha256 = "b608a08344b61a5557718c5257cc39ec1465f7268daca2d921da5f07cfbb9cbc";
  };
  twentyNineteen = buildTheme {
    url = "https://downloads.wordpress.org/theme/twentynineteen.1.9.zip";
    sha256 = "93f49a80881fcaf3cd3cc51ac4d905249f82b35808ce313c716aea3009bdaf1a";
  };
  twentyTwenty = buildTheme {
    url = "https://downloads.wordpress.org/theme/twentytwenty.1.6.zip";
    sha256 = "57f5b927bfd3e3044b8ea66b1ac213a700ed6753aa65fce786b5267a1103685f";
  };
  oceanWP = buildTheme {
    url = "https://downloads.wordpress.org/theme/oceanwp.2.0.2.zip";
    sha256 = "582a635a62d1400867da4c277602f56bd91f5f83e3b2e39a4f5207461873e422";
  };
  trance = buildTheme {
    url = "https://downloads.wordpress.org/theme/trance.1.14.zip";
    sha256 = "7a1b55c8ec99b963f162b2fae2908c4e6cf9ae280133e488b0fcd22864349b71";
  };
}
