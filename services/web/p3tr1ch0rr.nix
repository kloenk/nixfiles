{ ... }:

let
  p3tr_locations = {
    "/" = { return = "301 https://twitch.tv/p3tr1ch0rr"; };
    "/discord" = { return = "301 https://discord.gg/8Y9dKHq7Zr"; };
    "/kofi" = { return = "301 https://ko-fi.com/p3tr1ch0rr"; };
    "/ko-fi" = { return = "301 https://ko-fi.com/p3tr1ch0rr"; };
    "/spotify" = { return = "301 https://open.spotify.com/user/chilsninkio"; };
    "/musik" = { return = "301 https://open.spotify.com/user/chilsninkio"; };
    "/music" = { return = "301 https://open.spotify.com/user/chilsninkio"; };
    "/insta" = { return = "301 https://instagram.com/p3tr_1ch0rr"; };
  };
in {
  networking.domains.subDomains = {
    "p3tr1ch0rr.de" = { };
    "web.p3tr1ch0rr.de" = { };
  };
  services.nginx.virtualHosts = {
    "p3tr1ch0rr.de" = {
      enableACME = true;
      forceSSL = true;
      locations = p3tr_locations;
    };
    "www.p3tr1ch0rr.de" = {
      enableACME = true;
      forceSSL = true;
      locations = p3tr_locations;
    };
  };
}
