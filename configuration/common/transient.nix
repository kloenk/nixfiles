{ lib, config, ... }:

{
  fileSystems."/var/lib/acme" = {
    device = "/persist/data/acme";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/root/.gnupg" = {
    device = "/persist/data/gnupg-root";
    fsType = "none";
    options = [ "bind" ];
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    neededForBoot = true;
  };

  systemd.services = with lib; listToAttrs (
   flatten (
     map (
       name: [
         # disable the real acme services
         (
           nameValuePair "acme-${name}" {
             ReadWritePaths = "/persist/data/acme";
             BindPaths = "/perist/data/acme:/var/lib/acme";
           }
         )
       ]
     ) (
       attrNames config.security.acme.certs
     )
   )
 );
}
