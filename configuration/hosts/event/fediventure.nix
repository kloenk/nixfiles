{ config, lib, pkgs, ... }:

let
  front = pkgs.workadventure.front.override { environment."JITSI_URL" = "communicate.unterbachersee.de"; };
in {

  services.workadventure.instances."world.event.unterbachersee.de" = {
    nginx.domain = "world.event.unterbachersee.de";
    frontend.urls.jitsi = "communicate.unterbachersee.de";
    #frontend.package = front;
    /*backend.package = wapkgs.back;
    puscher.package = wapkgs.pusher;
    frontend.package = wapkgs.front;
    maps.package = wapkgs.maps;*/
  };

  services.nginx.virtualHosts."world.event.unterbachersee.de" = {
    enableACME = true;
    forceSSL = true;
    locations."/robots.txt".return = "200 \"User-agent: *\\nDisallow: /\\n\"";
  };
}
