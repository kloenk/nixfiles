{ config, lib, pkgs, ... }:

{

  services.workadventure.instances.play = {
    nginx.default = true;
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
