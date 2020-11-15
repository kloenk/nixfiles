{ ... }:

{
  #networking.hosts."stream-testing" = [ "127.0.0.1" "::1" ];
  networking.hosts."127.0.0.1" = [ "stream-testing" "stream-testing.local" ];
  networking.hosts."::1"       = [ "stream-testing" "stream-testing.local" ];

  services.osp = {
    enable = true;
    hostName = "stream-testing";
  };

  services.nginx.virtualHosts."stream-testing" = {
    #enableACME = true;
    #forceSSL = true;
  };
}
