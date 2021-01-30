{ config, lib, pkgs, ... }:

let
  front = pkgs.workadventure.front.override { environment."JITSI_URL" = "meet.kloenk.dev"; };
in {

  services.workadventure.instances."play.kloenk.dev" = {
    nginx.domain = "play.kloenk.dev";
    frontend.urls.jitsi = "meet.kloenk.dev";
    #frontend.package = front;
    /*backend.package = wapkgs.back;
    puscher.package = wapkgs.pusher;
    frontend.package = wapkgs.front;
    maps.package = wapkgs.maps;*/
  };

  services.nginx.virtualHosts."play.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
  };
}
