{ lib, self, ... }:

let params = import ./ssh-params.nix;
in {
  programs.ssh = {
    ciphers = params.Ciphers;
    macs = params.Macs;
    kexAlgorithms = params.KexAlgorithms;
    hostKeyAlgorithms = params.HostKeyAlgorithms;
    pubkeyAcceptedKeyTypes = [
      "sk-ssh-ed25519@openssh.com"
      "ssh-ed25519"
      # Slightly less secure options:
      # - RSA is weakening
      "ssh-rsa"
      # - NIST P-256 curve may or may not be backdoored
      "ecdsa-sha2-nistp256"
    ];
    extraConfig = ''
      ControlMaster auto
      ControlPath ~/.ssh/%r@%h.sock
      ControlPersist 5m
      VerifyHostKeyDNS yes

      Host *.kloenk.de
        Port 62954

      Host *.kloenk.dev
        Port 62954

      Host *.studs.math.uni-wuppertal.de
        Port 22
        User fbehrens
        ControlPersist 24h

      Host *.studs
        Hostname %h.math.uni-wuppertal.de
        Port 22
        User fbehrens
        ControlPersist 24h

      Host l???
        Hostname %h.studs.math.uni-wuppertal.de
        Port 22
        User fbehrens
        ControlPersist 24h

      Host gitlab.com github.com git.sr.ht
        User git
        RequestTTY no

      Host cyberchaos.dev
        Port 62954
        Host cyberchaos.dev
        ForwardAgent no
        RequestTTY no

      Host *
        ForwardAgent no
        HashKnownHosts no
        UserKnownHostsFile ~/.ssh/known_hosts
    '';
  };

  programs.ssh.knownHosts = {
    thrain = {
      hostNames = [ "192.168.178.248" ];
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/2kA6GZfQ/laY7hrzXJeM9WGuzHFtcpgbQLXGyiHqC";
    };

    cyberchaos = {
      hostNames = [ "cyberchaos.dev" ];
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB994/Dz2G4vKDYeC1PQ445OKaaJLWdM6I+PBvHRDLa5";
    };

    fleetyards_staging = {
      hostNames = [ "fleetyards.dev" ];
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPxwVNbqCyHNwN/jCSAZlpDkiGof8BdtaSBbHpyB55tE";
    };
    fleetyards_prod = {
      hostNames = [ "fleetyards.net" ];
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnP3Tvyvk3hoZLOuFVokhu37tCXODGxHhVlCRtllAZW";
    };

    poccase = {
      hostNames = [ "poccase1.eventphone.de" ];
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKZmxA9Tb8oDwRKqAe+uOgjVMiiYSLtJccbslJ+t4Yq";
    };

    # well known hosts
    "aarch64.nixos.community" = {
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUTz5i9u5H2FHNAmZJyoJfIGyUm/HfGhfwnc142L3ds";
    };
    "gitlab.com" = {
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    };
    "github.com" = {
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
    "git.sr.ht" = {
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
    };
  };
}
