{ config, pkgs, ... }:
let certDirectory = config.security.acme.certs.vpn.directory;
in {
  #imports = [ ../../profiles/strongswan.nix ];

  k.strongswan = {
    enable = true;
    acme.enable = true;
    babel = {
      enable = true;
      public = true;
      id = {
        v4 = 1;
        v6 = "5662";
      };
      bird.extraConfig = ''
        function net_buw() {
          if net.type = NET_IP4 then return net ~ [ 132.195.0.0/21+, 132.195.0.0/16+ ];
          return false;
        }
        protocol direct direct_buw {
          interface "buw0";
          interface "lo";
          # has no v6
          ipv4 {
            table babel4;
            import filter {
              if net_buw() then accept;
              reject;
            };
          };
        }
      '';
    };
  };
}
