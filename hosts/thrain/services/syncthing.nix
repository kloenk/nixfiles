{ config, ... }:

{
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    dataDir = "/persist/data/syncthing";
    configDir = "${config.services.syncthing.dataDir}";
    user = "kloenk";
    group = "users";

    settings = {
      options.urAccepted = -1;
      devices = {
        elrond = {
          addresses = [ "tcp://192.168.178.247" "tcp://192.168.242.204" ];
          id =
            "YAHWJOS-HXERGLI-3RKPLGH-NNIQJ2J-BH3HA3M-FQJJCWW-L57SCXD-Y4MTWQN";
        };
        frodo = {
          id =
            "AHVY7YB-PIQ24ZI-FX7ZAMC-XFNBSHF-57AWZF6-S76V6G5-5UXGOJV-BWNJYAW";
        };
      };

      folders = {
        "projects" = {
          id = "projects";
          label = "Developer";
          path = "/persist/data/syncthing/data/projects";
          devices = [ "elrond" "frodo" ];
        };
      };
    };
  };

  services.nginx.virtualHosts."syncthing.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    listenAddresses = [ "192.168.242.101" "[2a01:4f8:c013:1a4b:ecba::101]" ];
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
  security.acme.certs."syncthing.thrain.net.kloenk.de".server =
    "https://acme.net.kloenk.de:8443/acme/acme/directory";

  users.users.kloenk.extraGroups = [ "syncthing" ];
}
