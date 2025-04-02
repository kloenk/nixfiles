{ ... }:

{
  imports = [
    ./wireguard.nix
    ./nginx.nix
    ./emacs.nix
    ./secureboot.nix
    ./strongswan
    ./pam_u2f.nix
    ./syncthing.nix
    ./mail.nix
    ./monitoring.nix
    ./vpn.nix
  ];
}
