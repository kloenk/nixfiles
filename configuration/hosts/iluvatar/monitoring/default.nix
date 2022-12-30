{ lib, config, pkgs, ... }:

{
  imports = [
    ./grafana.nix
    ./influx.nix
  ];
}
