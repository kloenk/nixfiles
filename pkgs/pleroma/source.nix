
{ fetchFromGitLab }:

rec {
  version = "2.2.0";
  src = fetchFromGitLab {
    domain = "git.pleroma.social";
    owner = "pleroma";
    repo = "pleroma";
    rev = "v2.2.0";
    sha256 = "04irvwxd5dlfl0jqmr15a13sn4iiwsq86ii3hxpp8a38xb0n52gv";
  };
}

