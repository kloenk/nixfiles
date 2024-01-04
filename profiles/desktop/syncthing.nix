{ lib, config, ... }:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = lib.mkDefault true;
    dataDir = lib.mkDefault "/home/kloenk/.syncthing";
    configDir = lib.mkDefault "${config.services.syncthing.dataDir}/conf";
    user = "kloenk";
    group = "users";
  };

  users.users.kloenk.extraGroups = [ "syncthing" ];

  services.nginx.virtualHosts."syncthing.${config.networking.hostName}.net.kloenk.de" =
    {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      listenAddresses = [ config.k.wg.ipv4 "[${config.k.wg.ipv6}]" ];
      locations."/" = {
        recommendedProxySettings = false; # self applied because host header
        extraConfig = ''
          proxy_set_header Host localhost;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Server $host;
        '';
        proxyPass = "http://localhost:8384";
      };

    };
  security.acme.certs."syncthing.${config.networking.hostName}.net.kloenk.de".server =
    "https://acme.net.kloenk.de:8443/acme/acme/directory";
}

