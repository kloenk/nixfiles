{ pkgs, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.enable = false;
  boot.initrd.enable = false;
  boot.isContainer = true;
  boot.loader.initScript.enable = true;
  ## login with empty password
  users.extraUsers.root.initialHashedPassword = "";

  environment.systemPackages = [ pkgs.kmod ];

  networking.firewall.enable = false;

  services.getty.helpLine = ''
    Log in as "root" with an empty password.
    If you are connect via serial console:
    Type Ctrl-a c to switch to the qemu console
    and `quit` to stop the VM.
  '';

  services.getty.autologinUser = lib.mkDefault "root";

  documentation.doc.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;
  documentation.info.enable = false;
  programs.bash.enableCompletion = false;
  programs.command-not-found.enable = false;

  console.enable = true;
  systemd.services."serial-getty@ttyS0".enable = true;
}
