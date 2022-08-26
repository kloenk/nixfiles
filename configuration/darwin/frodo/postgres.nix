{ config, lib, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    dataDir = "/Users/kloenk/Developer/postgresql/14";
  };
}
