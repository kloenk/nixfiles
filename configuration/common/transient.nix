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
         # fix acme serviceConfig
         (
           nameValuePair "acme-${name}" {
             serviceConfig.ReadWritePaths = [ "/persist/data/acme" ];
             serviceConfig.BindPaths = mkBefore [ 
               "/persist/data/acme:/var/lib/acme"
             ];
           }
         )
         (
           nameValuePair "acme-selfsigned-${name}" {
             serviceConfig.ReadWritePaths = [ "/persist/data/acme" ];
             serviceConfig.BindPaths = mkBefore [ 
               "/persist/data/acme:/var/lib/acme"
             ];
           }
         )
       ]
     ) (
       attrNames config.security.acme.certs
     )
   )
 );
}
