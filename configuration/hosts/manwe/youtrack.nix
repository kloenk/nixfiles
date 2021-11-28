{ config, lib, pkgs, ... }:

{
  services.youtrack = {
    enable = true;
    port = 8085;
    baseUrl = "restya.kloenk.dev";
    virtualHost = "restya.kloenk.dev";
    statePath = "/persist/data/youtrack";
  };


  services.nginx.virtualHosts."restya.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    http2 = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "youtrack"
  ];

}
