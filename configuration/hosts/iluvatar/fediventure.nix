{ inputs, config, lib, pkgs, ... }:

let
  wapkgs = import (inputs.fediventure + "/third_party/workadventure-nix.nix") { fediventure = null; inherit lib pkgs; };
in {
  imports = [
    (inputs.fediventure + "/ops/nixos/modules/workadventure/workadventure.nix")
  ];

  services.workadventure.instances.play = {
    nginx.default = true;
    nginx.domain = "play.kloenk.dev";
    backend.package = wapkgs.back;
    puscher.package = wapkgs.pusher;
    frontend.package = wapkgs.front;
    maps.package = wapkgs.maps;
  };
}
