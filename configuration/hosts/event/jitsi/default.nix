{ config, lib, pkgs, ... }:

{
  imports = [
     ./turn.nix
     #./exporter.nix
   ];

   services.jitsi-videobridge.openFirewall = true;
   services.jitsi-meet = {
     enable = true;
     hostName = "communicate.unterbachersee.de";
     config = {
       useIPv6 = true;
       useStunTurn = true;
       startAudioOnly = true;
       desktopSharingFirefoxDisabled = false;
       desktopSharingFrameRate.min = 5;
       desktopSharingFrameRate.max = 10;
       disableThirdPartyRequests = true;
       p2p = {
         useStunTurn = true;
         stunServers = [
           { urls = "stun:turn.unterbachersee.de:3478"; }
           { urls = "stun:turn.unterbachersee.de:3479"; }
         ];
       };
     };
   };

   services.nginx.virtualHosts."communicate.unterbachersee.de" = {
     enableACME = true;
     forceSSL   = true;
     extraConfig = ''
       add_header Referrer-Policy "no-referrer-when-downgrade" always;
       add_header Strict-Transport-Security $hsts_header always;
       add_header X-Content-Type-Options "nosniff";
       add_header X-Frame-Options "ALLOW";
       add_header X-Xss-Protection "1; mode=block";
     '';
   };
}
