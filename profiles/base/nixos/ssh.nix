{ lib, ... }:

let params = import ../ssh-params.nix;
in {
  services.openssh = {
    enable = true;
    ports = [ 62954 ];
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = lib.mkOverride 1100 "prohibit-password";
      inherit (params) Ciphers Macs KexAlgorithms;
      HostKeyAlgorithms = lib.concatStringsSep "," params.HostKeyAlgorithms;
    };

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
