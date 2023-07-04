{ config, ... }:

{
  security.acme.defaults.email = "ca@kloenk.de";
  services.nginx.virtualHosts."${config.networking.hostName}.kloenk.dev" = {
    #serverAliases = [ "default" ];
    #enableACME = true;
    #forceSSL = true;
    locations."/public/".alias = lib.mkDefault "/persist/data/public/";
    locations."/public/".extraConfig = "autoindex on;";
  };
}