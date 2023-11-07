{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")

    ./common
  ];

  boot.supportedFilesystems = [ "bcachefs" ];
}
