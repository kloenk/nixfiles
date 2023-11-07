{ cofig, pkgs, ... }:

{
  services.heisenbridge = {
    enable = true;
    homeserver = "http://localhost:8008";
    owner = "@kloenk:kloenk.eu";
  };
}
