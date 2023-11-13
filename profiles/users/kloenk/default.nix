{ lib, ... }:

{
  imports = [ ./kloenk.nix ./hm.nix ];

  users.users.kloenk = {
    isNormalUser = true;
    uid = lib.mkDefault 1000;
    extraGroups = [ "wheel" "bluetooth" "libvirtd" ];
  };

  programs.gnupg.agent = {
    enable = lib.mkDefault true;
    enableSSHSupport = true;
  };
}
