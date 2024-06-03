{ ... }:

let
  hostName = "inventree.kloenk.dev";
in
{
  services.inventree = {
    enable = true;
    inherit hostName;
  };

  services.nginx.virtualHosts.${hostName} = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
  };
}
