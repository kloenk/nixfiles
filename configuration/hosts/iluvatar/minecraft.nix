{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "minecraft-server" ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/persist/data/minecraft/";

    servers.escapetheminecraft = {
      enable = true;
      openFirewall = true;
      whitelist = {
        Kloenk = "c16d92b1-eca1-4387-93de-4f27de56ff03";
        escapetheaverage = "25482f83-6048-4389-a78a-b8abe15f8614";

        # Community section
        #Kati21102007 = "";
      };

      serverProperties = {
        "level-seed" = 629422449754953815;
        gamemode = "survival";
        "enable-command-block" = true;
        "enforce-secure-profile" = false;
        "leve-name" = "world";
        motd = "Escapetheaverage Minecraft server";
        "query.port" = 25565;
        pvp = true;
        "server-ip" = "escapetheminecraft.kloenk.dev";
      };

      package = pkgs.fabricServers.fabric-1_19;
      jvmOpts = "-Xmx2G -Xms1G";

      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (map pkgs.fetchModrinthMod
          (builtins.attrValues {
            FabricAPI = {
              id = "3KmOcp6b";
              hash =
                "0cb35b8f42302001e82f1a08b7b9b70070dcc7488b43d08d93d1e2adafd6cdc7";
            };

            Lithium = {
              id = "sIKhU9s4";
              hash =
                "fbc0efb6db294155c5705672731e9ca58ddc5b36fb75544e1693514ca8a282d6";
            };
            Phosphor = {
              id = "Di0Jgej2";
              hash =
                "9e93a97d8fe149b6b8f782417432768c708704c6825ad2af3d280628698db895";
            };
            Taterzens = {
              id = "TV31TyVu";
              hash =
                "f88b4230b36dffcb7d522039c85290b1c4973d58fa4b15ca6d5598d6602b7e5d";
            };
            TraderNPCs = {
              id = "gRw25odj";
              hash =
                "c97cac2c6d363047c49d574c922e6e9f90412713f124716b352f23c8862656bd";
            };
            C2ME = {
              id = "yU5A8Qx5";
              hash =
                "528c8791f1c4ea538948689e410b2e6c8fe15951772f82558922257b4faf6696";
            };
            LazyDFU = {
              id = "4SHylIO9";
              hash =
                "8c7993348a12d607950266e7aad1040ac99dd8fe35bb43a96cc7ff3404e77c5d";
            };
            FerriteCore = {
              id = "7epbwkFg";
              hash =
                "58ab281bc8efdb1a56dff38d6f143d2e53df335656d589adff8f07d082dbea77";
            };
            Krypton = {
              id = "UJ6FlFnK";
              hash =
                "2383b86960752fef9f97d67f3619f7f022d824f13676bb8888db7fea4ad1f76a";
            };
            BlueMap = {
              id = "URGg6hB0";
              hash =
                "b50d1402c8fe2b34f57db53acd18ae6910a6c31821f2106941bc493b36ae41a7";
            };

            /* Starlight = { id = "4ew9whL8"; hash = "00w0alwq2bnbi1grxd2c22kylv93841k8dh0d5501cl57j7p0hgb"; };
               Lithium = { id = "MoF1cn6g"; hash = "0gw75p4zri2l582zp6l92vcvpywsqafhzc5a61jcpgasjsp378v1"; };
               FerriteCore = { id = "776Z5oW9"; hash = "1gvy92q1dy6zb7335yxib4ykbqrdvfxwwb2a40vrn7gkkcafh6dh"; };
               Krypton = { id = "vJQ7plH2"; hash = "1y6sn1pjd9kl2ig73zg3zb7f6p2a36sa9f7gjzawrpnp0q6az4cf"; };
               LazyDFU = { id = "C6e265zK"; hash = "1fga62yiz8189qrl33l4p5m05ic90dda3y9bg7iji6z97p4js8mj"; };
               C2ME = { id = "5P5gJ4ws"; hash = "1xyhyy7v99k4cvxq5b47jgra481m73zx025ylps0kjlwx7b90jkh"; };
            */
          }));
      };
    };
  };

  services.nginx.virtualHosts."escapetheminecraft.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;

    root = "/persist/data/minecraft/escapetheminecraft/bluemap/web";

    locations = {
      "/".tryFiles = "$uri /index.php";
      "~* /(maps/[^/\\s]*/live/.*)".proxyPass = "http://127.0.0.1:8100/$1";
      "~ \\.php$" = {
        fastcgiParams = {
          SCRIPT_FILENAME = "$document_root$fastcgi_script_name";
        };
        extraConfig = ''
          fastcgi_pass  unix:${config.services.phpfpm.pools.bluemap.socket};
          fastcgi_index index.php;
        '';
      };
    };
  };

  services.phpfpm.pools.bluemap = {
    user = "minecraft";
    settings = {
      pm = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
  };

  services.mysql.ensureDatabases = [ "minecraft_escapetheaverage" ];
  services.mysql.ensureUsers = [
    {
      name = "minecraft";
      ensurePermissions = {
        "minecraft_escapetheaverage.*" = "ALL PRIVILEGES";
      };
    }
    {
      name = "nginx";
      ensurePermissions = { "minecraft_escapetheaverage.*" = "SELECT"; };
    }
  ];

  /* services.postgresql = {
       ensureDatabases = [ "minecraft_escapetheaverage" ];
       ensureUsers = [
         {
           name = "minecraft";
           ensurePermissions."DATABASE minecraft_escapetheaverage" = "ALL PRIVILEGES";
         }
       ];
     };
  */

  services.restic.backups.minecraft = {
    passwordFile = config.sops.secrets."minecraft/restic".path;
    initialize = true;
    timerConfig = {
      OnBootSec = "120";
      OnCalendar = "*-*-* *:00:00";
      RandomizedDelaySec = "10m";
    };
    paths = [
      "/persist/data/minecraft/escapetheminecraft/world"
      "/persist/data/minecraft/escapetheminecraft/config"
      "/persist/data/minecraft/escapetheminecraft/ops.json"
      "/persist/data/minecraft/escapetheminecraft/banned-*.json"

    ];
    repository = "rest:http://192.168.242.103:8080/minecraft";
    user = "minecraft";
  };

  sops.secrets."minecraft/restic".owner = "minecraft";

  /* nixpkgs.config.allowUnfreePredicate = pkg:
       builtins.elem (lib.getName pkg) [ "minecraft-20w20a" "minecraft-server" ];

     services.minecraft-server = {
       enable = true;
       dataDir = "/persist/data/minecraft/eljoy";
       declarative = true;
       eula = true;
       package = pkgs.minecraft-20w20a;
       openFirewall = true;
       stopCommands = ''
         echo "say This server is stopping in 3.."
         sleep 1
         echo "say 2.."
         sleep 1
         echo "say 1.."
         sleep 1
       '';
       serverProperties = {
         server-port = 25565;
         max-players = 20;
         motd = builtins.trace "TODO: set motd for minecraft"
           "please provide a motd for me";
         difficulty = "normal";
         force-gamemode = true;
         white-list = true;
         #"rcon.password"
       };
       whitelist = {
         kloenk = "c16d92b1-eca1-4387-93de-4f27de56ff03";
         Drachensegler = "7698b19e-6cb9-4ce1-9a16-3f578263eea3";
         Ennsn456 = "812e9708-f096-41bc-a64d-9251c211dd32";
       };
     };
  */
  /* systemd.services.minecraft-server.serviceConfig.StandardInput = "socket";
     systemd.services.minecraft-server.serviceConfig.StandardOutput = "journal";

     systemd.sockets.minecraft-server = {
       description = "controll process for the minecraft server";
       socketConfig.ListenFIFO = "/run/minecraft/stdin";
       wantedBy = [ "sockets.target" ];
     };
  */
}
