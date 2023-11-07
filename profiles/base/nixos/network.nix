{ lib, config, ... }:

{
  networking.useNetworkd = lib.mkDefault true;
  networking.search = [ "kloenk.de" ];
  networking.hosts = {
    "127.0.0.1" = let
      hostName = config.networking.hostName;
    in [ hostName "${hostName}.kloenk.de" "${hostName}.kloenk.eu" "${hostName}.kloenk.dev" ];
  };
  networking.useDHCP = lib.mkDefault false;
  networking.interfaces.lo = lib.mkDefault {
    ipv4.addresses = [
      {
        address = "127.0.0.1";
        prefixLength = 8;
      }
      {
        address = "127.0.0.53";
        prefixLength = 32;
      }
    ];
  };

  nftables.enable = true;
  nftables.forwardPolicy = lib.mkDefault "drop";
}