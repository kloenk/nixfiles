{ ... }:

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
}