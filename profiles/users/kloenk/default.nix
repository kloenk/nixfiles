{ lib, ... }:

{
  imports = [
    ./kloenk.nix
  ];

  users.users.kloenk = {
    uid = lib.mkDefault 1000;
    extraGroups = [ "wheel" "bluetooth" "libvirtd" ];
  };

  programs.gnupg.agent = {
    enable = lib.mkDefault true;
    enableSSHSupport = true;
  };
}