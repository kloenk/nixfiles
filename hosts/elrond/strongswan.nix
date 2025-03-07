{ config, pkgs, ... }:

{
  k.strongswan = {
    enable = true;
    package = pkgs.strongswanTPM;
    cert = ../../lib/vpn/elrond.cert.pem;
    babel = {
      enable = true;
      id = {
        v4 = 150;
        v6 = "59A1";
      };
    };
  };

  services.strongswan-swanctl.swanctl.secrets.token.ak_ecc.handle =
    "0x81010004";
}

