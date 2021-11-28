{ config, lib, pkgs, ... }:

{
  services.jira = {
    enable = true;
    home = "/persist/data/jira";
  };

  services.nginx.virtualHosts."restya.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    http2 = true;
    locations."/" = {
      proxyPass = "http://${config.services.jira.listenAddress}:${toString config.services.jira.listenPort}";

    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "atlassian-jira"
    "oraclejre"
  ];
}
