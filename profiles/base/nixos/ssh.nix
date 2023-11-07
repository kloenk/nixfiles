{ ... }:

{
  services.openssh = {
    enable = true;
    ports = [ 62954 ];
    settings.PasswordAuthentication = lib.mkDefault
      (if (config.networking.hostName != "kexec") then false else true);
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = lib.mkDefault "prohibit-password";

    hostKeys = [{
      path = "/persist/data/openssh/ed25519_key";
      type = "ed25519";
    }];

    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };
  sops.age.sshKeyPaths = [ "/persist/data/openssh/ed25519_key" ];
}