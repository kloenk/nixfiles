{ config, lib, pkgs, ... }:

{
  users = {
    users.gitlab-runner = {
      isSystemUser = true;
      group = "gitlab-runner";
    };
    groups.gitlab-runner = { };
  };

  systemd.services.gitlab-runner.serviceConfig = {
    User = "gitlab-runner";
    Group = "gitlab-runner";
    DynamicUser = lib.mkForce false;
  };

  virtualisation.docker.autoPrune = {
    enable = true;
    flags = [ "--all" "--filter until=168h" ];
  };

  ## Docker does not enable IPv6 per default
  #virtualisation.docker.extraOptions = "--ipv6 --fixed-cidr-v6 fd00::/80";
  #networking.firewall.extraCommands = ''
  #  ip6tables -t nat -A POSTROUTING -s fd00::/80 ! -o docker0 -j MASQUERADE
  #'';

  # prevent race condition "Another app is currently holding the xtables lock"
  systemd.services.docker.after = [ "firewall.service" ];

  services.gitlab-runner = {
    enable = true;
    concurrent = 6;
    checkInterval = 30;
    services = rec {
      default = {
        registrationConfigFile =
          config.petabyte.secrets."gitlab/default-env".path;
        dockerImage = "debian:stable";
      };
      docker-images = {
        registrationConfigFile =
          config.petabyte.secrets."gitlab/default-env".path;
        dockerImage = "docker:stable";
        dockerVolumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
        tagList = [ "docker-images" ];
      };
      ## runner for building docker images
      #docker-images = {
      #  registrationConfigFile = "/run/secrets/gitlab-runner-registration";
      #  dockerImage = "docker:stable";
      #  dockerVolumes = [
      #    "/var/run/docker.sock:/var/run/docker.sock"
      #  ];
      #  tagList = [ "docker-images" ];
      #};
    };
  };

  petabyte.secrets."gitlab/default-env".owner = "gitlab-runner";
}
