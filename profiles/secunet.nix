{ lib, config, ... }:

let
  inherit (lib) mkEnableOption;
  cfg = config.k.secunet;
in {
  nix = {
    settings = {
      substituters = [
        "http://cache.factory.secunet.com/factory-1"
        # "http://seven-cache02.syseleven.seven.secunet.com"
      ];
      trusted-public-keys =
        [ "factory-1:Ai12PqfDkRmLzju4eE5/ucuDGXw4J31d3aTrz4TZKrk=" ];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "secunet-aarch64-1";
        protocol = "ssh-ng";
        systems = [ "aarch64-linux" ];
        maxJobs = 40;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
      {
        hostName = "secunet-x86_64-1";
        protocol = "ssh-ng";
        systems = [ "x86_64-linux" ];
        maxJobs = 40;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
    ];
  };

  programs.ssh = {
    extraConfig = ''
      Host secunet-aarch64-1
        #HostName fd00:5ec:0:8008::3
        HostName nixbuilder-arm-01.factory.secunet.com
        User nixbuild
        IdentitiesOnly yes
        IdentityFile ${config.sops.secrets."secunet/nix/ed25519".path}
      Host secunet-x86_64-1
        #HostName fd00:5ec:0:8008::6
        HostName nixbuilder-amd-01.factory.secunet.com
        User nixbuild
        IdentitiesOnly yes
        IdentityFile ${config.sops.secrets."secunet/nix/ed25519".path}
    '';
    knownHosts = {
      # aarch64-01
      "fd00:5ec:0:8008::3".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9NXi+pEIjOcsgh6uIcLxyGAP1pnp87E0T8dBj8wahG";
      # x86-64-01
      "fd00:5ec:0:8008::6".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZM4vpq5mrih7vS8leIZB1wJok4yVRqVJ30L1euVA45";
    };
  };

  sops.secrets."secunet/nix/ed25519" = {
    sopsFile = ../secrets/shared/secunet.yaml;
    owner = "root";
  };

  specialisation.office.configuration = {
    networking.proxy.default = "http://proxy.secunet.de:3128";
    networking.proxy.noProxy = "127.0.0.1,localhost";
  };
}
