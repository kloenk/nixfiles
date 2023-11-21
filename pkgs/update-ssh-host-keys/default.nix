{ lib, substituteAll, bash, coreutils, openssh, git, nix, gnused
, baseDomain ? "net.kloenk.de", port ? 62954 }:

substituteAll {
  name = "deploy-secrets";
  version = "0.0.1";

  src = ./update-ssh-host-keys.sh;

  isExecutable = true;

  shell = "${bash}/bin/bash";
  path = lib.makeBinPath [ coreutils openssh git nix gnused ];
  inherit baseDomain port;
}
