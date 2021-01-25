{ config, lib, pkgs, ... }:

{
  petabyte.secrets.turn.owner = "turnserver";

   # sneak in secret
   # FIXME: this is still world-readable in the process list, just not in the nix store anymore
   nixpkgs.config.packageOverrides = pkgs: {
     coturn = pkgs.runCommand "coturn-with-secret" {
       buildInputs = with pkgs; [ makeWrapper ];
     } ''
       mkdir -p $out/bin
       ln -s ${pkgs.coturn}/bin/turnserver $out/bin/turnserver
       wrapProgram $out/bin/turnserver \
         --add-flags '--static-auth-secret $(cat ${config.petabyte.secrets.turn.path})'
     '';
   };

   networking.firewall.allowedTCPPorts = [ 3478 3479 5349 5350 ];
   networking.firewall.allowedUDPPorts = [ 3478 3479 5349 5350 ];
   networking.firewall.allowedUDPPortRanges = [ { from = 49152; to = 65535; } ];

   services.coturn = {
     enable = true;
     use-auth-secret = true;
     realm = "turn.kloenk.dev";
     no-tcp-relay = true;
     no-tls = true;
     no-dtls = true;
     extraConfig = ''
       user-quota=12
       total-quota=1200
       denied-peer-ip=10.0.0.0-10.255.255.255
       denied-peer-ip=192.168.0.0-192.168.255.255
       denied-peer-ip=172.16.0.0-172.31.255.255
     '';
   };
}
