{ lib, self, ... }:

{
  programs.ssh = {
    pubkeyAcceptedKeyTypes = [ "ecdsa-sha2-nistp256" ];
    extraConfig = ''
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
  };
}
