{ ... }:

{
  imports =
    [ ./wireguard.nix ./nginx.nix ./emacs.nix ./secureboot.nix ./pam_u2f.nix ];
}
