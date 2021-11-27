{ config, pkgs, lib, ... }:

let
  commonHeaders = lib.concatStringsSep "\n"
    (lib.filter (line: lib.hasPrefix "add_header" line)
      (lib.splitString "\n" config.services.nginx.commonHttpConfig));
in {
  services.restya-board = {
    enable = true;
    virtualHost = {
      serverName = "restya.kloenk.dev";
      
    };
  };

  services.nginx.virtualHosts."restya.kloenk.dev" = {
    enableACME = true;
	enableSSL = lib.mkForce true;
    forceSSL = true;
	locations."~* \\.(css|js|less|html|ttf|woff|jpg|jpeg|gif|png|bmp|ico)" = {
      extraConfig = ''
        ${commonHeaders}
      '';
    };
  };
}
