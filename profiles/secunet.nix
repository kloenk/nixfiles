{ config, ... }:

{
  nix = {
    settings = {
      substituters = [
        "http://seven-cache01.syseleven.seven.secunet.com"
        # "http://seven-cache02.syseleven.seven.secunet.com"
      ];
      trusted-public-keys =
        [ "seven-1:M1znlh60ChXxeuOXaxFVLTrmeJS+UpYVfmI5fmX2Itc=" ];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  specialisation.office.configuration = {
    networking.proxy.default = "http://proxy.secunet.de:3128";
    networking.proxy.noProxy = "127.0.0.1,localhost";
  };
}
