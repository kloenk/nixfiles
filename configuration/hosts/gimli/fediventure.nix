{ config, lib, pkgs, ... }:

{

  services.workadventure.instances."play.kloenk.dev" = {
    nginx.domain = "play.kloenk.dev";
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
