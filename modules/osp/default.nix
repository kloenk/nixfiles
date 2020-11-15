{ config, lib, pkgs, ... }:

let
  inherit (lib) types mkEnableOption mkOption mkIf;

  cfg = config.services.osp;
in {
  _file = ./default.nix;
  options.services.osp = {
    enable = mkEnableOption "Open Streaming Platform";

    gunicorn.workers = mkOption {
      type = types.ints.positive;
      default = 10;
      example = 20;
      description = ''
        The number of worker processes for handling requests.
      '';
    };

    hostName = mkOption {
      type = types.str;
      example = "osp.example.com";
      description = ''
        Domain for the server
      '';
    };
  };

  config = mkIf cfg.enable {
    # assertsions

    users.users.osp = {
      description = "osp server";
      group = "osp";
      isSystemUser = true;
      home = "/var/lib/osp";
    };
    users.groups.osp = { members = [ config.services.nginx.user ]; };

    systemd.services = {
      osp-migrate = {
        description = "Open Streaming Server database Migration";
        wantedBy = [ "multi-user.target" ];
        after = [ "redis.service" "networking.target" ];
        restartIfChanged = true;

        preStart = ''
          #cp -r ${pkgs.osp}* /var/lib/osp
          #chmod -R +r /var/lib/osp
          umask 0007
          rm -rf /var/lib/osp/osp
          mkdir -p /var/lib/osp/osp
          cp -r ${pkgs.osp}/* /var/lib/osp/osp
          chmod -R u+w /var/lib/osp/osp
        '';

        script = ''
          if [ -d /var/lib/osp/migrations ]; then
            ${pkgs.osp}/bin/manage db migrate
          else
            ${pkgs.osp}/bin/manage db init
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          User = "osp";
          Group = "osp";
          WorkingDirectory = "/var/lib/osp";
          #ExecStart = "${pkgs.osp}/bin/manage db init";
          NoNewPrivileges = true;
          ProtectSystem = true;
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          #PrivateNetwork = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          #RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
          RestrictNamespaces = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
        };
      };

      osp-gunicorn = let penv = pkgs.osp.penv;
      in {
        description = "Open Streaming Server Gunicorn process";
        #wantedBy = [ "multi-user.target" ];
        after = [ "osp-migrate.service" ];

        restartIfChanged = true;

        environment.PYTHONPATH =
          "${penv}/${penv.sitePackages}:/var/lib/osp/osp";

        preStart = ''
          umask 0007
          rm -rf /var/lib/osp/osp
          mkdir -p /var/lib/osp/osp
          cp -r ${pkgs.osp}/* /var/lib/osp/osp
          chmod -R u+w /var/lib/osp/osp
        '';

        serviceConfig = {
          Type = "notify";
          User = "osp";
          Group = "osp";
          RuntimeDirectory = "gunicorn";
          WorkingDirectory = "/var/lib/osp/osp";
          ExecStart = "${penv}/bin/gunicorn app:app -k gevent";
          ExecReload =
            "${pkgs.utillinux}/bin/kill -s HUP $MAINPID --bind fd://$LISTEN_FDS";
          KillMode = "mixed";
          TimeoutStopSec = 5;
          PrivateTmp = true;
        };
      };

      /* osp-gunicorn = {
           description = "Open Streaming Server Gunicorn process";
           wantedBy = [ "multi-user.target" ];
           after = [ "osp-migrate.service" "networking.target" ];
           restartIfChanged = true;
           #restrartTriggers

           environment = let
             penv = pkgs.osp.penv;
           in {
             PYTHONPATH = "${penv}/${penv.sitePackages}";
           };

           preStart = ''
             #cp -r ${pkgs.osp}* /var/lib/osp
             #chmod -R +r /var/lib/osp
             umask 0007
             rm -rf /var/lib/osp/osp
             mkdir -p /var/lib/osp/osp
             cp -r ${pkgs.osp}/* /var/lib/osp/osp
             chmod -R u+w /var/lib/osp/osp
           '';

           script = ''
             cd osp
             ${pkgs.python37.pkgs.gunicorn}/bin/gunicorn app:app \
                 #--name osp-gunicorn-worker \
                 --workers ${toString cfg.gunicorn.workers} \
                 -k geventwebsocket.gunicorn.workers.GeventWebSocketWorker \
                 --bind unix:/run/osp/gunicorn.sock
           '';

           serviceConfig = {
             User = "osp";
             Group = "osp";
             WorkingDirectory = "/var/lib/osp";
             #ExecStart = ''${pkgs.python37.pkgs.gunicorn}/bin/gunicorn app:app \
             #    --name osp-gunicorn-worker \
             #    --workers ${toString cfg.gunicorn.workers} \
             #    -k geventwebsocket.gunicorn.workers.GeventWebSocketWorker \
             #    --bind unix:/run/osp/gunicorn.sock
             #'';

             Restart = "on-failure";
             RestartSec = "2s";

             # NoNewPrivileges = true;
             # ProtectSystem = true;
             # ProtectHome = true;
             # PrivateTmp = true;
             # PrivateDevices = true;
             # #PrivateNetwork = true;
             # ProtectKernelTunables = true;
             # ProtectKernelModules = true;
             # ProtectControlGroups = true;
             # #RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
             # RestrictNamespaces = true;
             LockPersonality = true;
             MemoryDenyWriteExecute = true;
           };
         };
      */
    };
    systemd.sockets.osp-gunicorn = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "/run/osp/gunicorn.sock" ];
      socketConfig = { User = config.services.nginx.user; };
    };

    services.nginx = {
      enable = true;
      package = lib.mkForce pkgs.nginx-rtmp;
      upstreams.osp = {
        servers."unix:/run/osp/gunicorn.sock" = {};
      };
      virtualHosts.${cfg.hostName} =
        let proxyPass = "http://osp/";
        in {
          locations."/" = {
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Server $host;
            '';
            inherit proxyPass;
          };
          locations."/socket.io" = {
            extraConfig = ''
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Host $host;

              proxy_set_header X-NginX-Proxy true;

              # prevents 502 bad gateway error
              proxy_buffers 8 32k;
              proxy_buffer_size 64k;

              proxy_redirect off;

              # enables WS support
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
            proxyPass = "${proxyPass + "socket.io"}";
          };
          locations."/ospAuth/" = {
            extraConfig = ''
              internal;

              set $channelID "";

              if ($request_uri ~* /videos/(.+)/(.+)) {
                  set $channelID $1;
              }

              if ($request_uri ~* /videos/(.*)/clips/(.*)\.(.+)) {
                  set $channelID $1;
              }

              if ($request_uri ~* /stream-thumb/(.*)\.(.+)) {
                  set $channelID $1;
              }

              if ($request_uri ~* /live-adapt/(.*)\.m3u8) {
                  set $channelID $1;
              }

              if ($request_uri ~* /live-adapt/(.*)_(.*)/(.*)\.(.*)) {
                  set $channelID $1;
              }

              if ($request_uri ~* /live/(.+)/(.+)) {
                  set $channelID $1;
              }

              if ($request_uri ~* /edge/(.+)/(.+)) {
                  set $channelID $1;
              }

              if ($request_uri ~* /edge-adapt/(.*)\.m3u8) {
                  set $channelID $1;
              }

              if ($request_uri ~* /edge-adapt/(.*)_(.*)/(.*)\.(.*)) {
                  set $channelID $1;
              }

              proxy_pass              ${proxyPass}auth;
              proxy_pass_request_body off;
              proxy_set_header        Content-Length "";
              proxy_set_header        X-Original-URI $request_uri;
              proxy_set_header        X-Channel-ID $channelID;
              #proxy_cache             auth_cache;
              proxy_cache_key         "$cookie_ospSession$http_x_auth_token$channelID";
              proxy_cache_valid       200 10m;
              proxy_ignore_headers Set-Cookie;
            '';
          };

          locations."/videos/".extraConfig = ''
            auth_request /ospAuth/;
            alias /var/lib/osp/videos/;
          '';

          locations."/videos/temp/".extraConfig = ''
            alias /var/lib/osp/videos/temp/;
          '';

          locations."/stream-thumb/".extraConfig = ''
            auth_request /ospAuth/;
            alias /var/lib/osp/stream-thumb/;
          '';

          locations."/live-adapt/".extraConfig = ''
            auth_request /ospAuth/;
            alias /var/lib/osp/live-adapt/;
          '';

          locations."/live/".extraConfig = ''
            auth_request /ospAuth/;
            alias /var/lip/osp/live/;
          '';

          locations."/static/".extraConfig = ''
            alias ${pkgs.osp}/static/;
          '';

          locations."~ /images(.*)".extraConfig = ''
            #add_header Cache-Control no-cache;

            #add_header 'Access-Control-Allow-Origin' '*' always;
            #add_header 'Access-Control-Expose-Headers' 'Content-Length';


            # allow CORS preflight requests
            if ($request_method = 'OPTIONS') {
                    #add_header 'Access-Control-Allow-Origin' '*';
                    #add_header 'Access-Control-Max-Age' 1728000;
                    #add_header 'Content-Type' 'text/plain charset=UTF-8';
                    #add_header 'Content-Length' 0;
                    return 204;
            }

            types {
                    application/vnd.apple.mpegurl m3u8;
                    video/mp2t ts;
            }

            root /var/lib/osp/www;

          '';

          locations."/edge/".extraConfig = ''
            auth_request /ospAuth/;
            rewrite ^/edge/(.*)$ $scheme://osp/live/$1 redirect;
          '';

          locations."/edge-adapt/".extraConfig = ''
            auth_request /ospAuth/;
            rewrite ^/edge-adapt/(.*)$ $scheme://osp/live-adapt/$1 redirect;
          '';

          locations."/http-bind/".extraConfig = ''
            proxy_pass  http://localhost:5280/bosh;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_redirect off;
            proxy_buffering off;
            proxy_read_timeout 65s;
            proxy_send_timeout 65s;
            keepalive_timeout 65s;
            tcp_nodelay on;
          '';

        };
        appendConfig = ''
					rtmp_auto_push on;
					rtmp_auto_push_reconnect 1s;
					
					rtmp {
                  upstream osp {
                    server unix:/run/osp/gunicorn.sock;
                  }
					        server {
					                listen 1935;
					                chunk_size 4096;
					
					                application stream {
					                        live on;
					                        record off;
					
					                        allow publish all;
					                        #deny publish all;
					                        allow play 127.0.0.1;
					
					                        on_publish http://127.0.0.1:5010/auth-key;
					                        on_publish_done http://osp/deauth-user;
					
					                }
					                application stream-data {
					                        live on;
					
					                        allow publish all;
					                        #deny publish all;
					                        allow play 127.0.0.1;
					
					                        on_publish http://osp/auth-user;
					                        push rtmp://osp/live/;
					                        push rtmp://osp/record/;
					
					                        hls on;
					                        hls_path /var/lib/osp/live;
					                        hls_fragment 1;
					                        hls_playlist_length 30s;
					
					                        hls_nested on;
					                        hls_fragment_naming system;
					
					                        recorder thumbnail {
					                            record video;
					                            record_max_frames 600;
					                            record_path /var/lib/osp/stream-thumb;
					                            record_interval 120s;
					
					                            exec_record_done ${pkgs.ffmpeg}/bin/ffmpeg -ss 00:00:01 -i $path -vcodec png -vframes 1 -an -f rawvideo -s 384x216  -y /var/www/stream-thumb/$name.png;
					                            exec_record_done ${pkgs.ffmpeg}/bin/ffmpeg -ss 00:00:00 -t 3 -i $path -filter_complex "[0:v] fps=30,scale=w=384:h=-1,split [a][b];[a] palettegen=stats_mode=single [p];[b][p] paletteuse=new=1" -y /var/www/stream-thumb/$name.gif;
					                        }
					                }
					
					                application stream-data-adapt {
					                        live on;
					
					                        allow publish all;
					                        #deny publish all;
					                        allow play 127.0.0.1;
					
					                        on_publish http://osp/auth-user;
					                        push rtmp://osp/live/;
					                        push rtmp://ops/record/;
					
					                        exec ${pkgs.ffmpeg}/bin/ffmpeg -i rtmp://127.0.0.1:1935/live/$name
					                                -c:v libx264 -c:a aac -b:a 128k -vf "scale=-2:720" -vsync 1 -copyts -start_at_zero -sws_flags lanczos -r 30 -g 30 -keyint_min 30 -force_key_frames "expr:gte(t,n_forced*1)" -tune zerolatency -preset ultrafast -crf 28 -maxrate 2096k -bufsize 4192k -threads 16 -f flv rtmp://localhost:1935/show/$name_720
					                                -c:v libx264 -c:a aac -b:a 96k -vf "scale=-2:480" -vsync 1 -copyts -start_at_zero -sws_flags lanczos -r 30 -g 30 -keyint_min 30 -force_key_frames "expr:gte(t,n_forced*1)" -tune zerolatency -preset ultrafast -crf 28 -maxrate 1200k -bufsize 2400k -threads 16 -f flv rtmp://localhost:1935/show/$name_480
					                                -c copy -f flv rtmp://localhost:1935/show/$name_src;
					
					
					                        recorder thumbnail {
					                            record video;
					                            record_max_frames 600;
					                            record_path /var/lib/osp/stream-thumb;
					                            record_interval 120s;
					
					                            exec_record_done ${pkgs.ffmpeg}/bin/ffmpeg -ss 00:00:01 -i $path -vcodec png -vframes 1 -an -f rawvideo -s 384x216  -y /var/www/stream-thumb/$name.png;
					                            exec_record_done ${pkgs.ffmpeg}/bin/ffmpeg -ss 00:00:00 -t 3 -i $path -filter_complex "[0:v] fps=30,scale=w=384:h=-1,split [a][b];[a] palettegen=stats_mode=single [p];[b][p] paletteuse=new=1" -y /var/www/stream-thumb/$name.gif;
					                        }
					
					                }
					
					                application show {
					                        live on;
					                        allow publish 127.0.0.1;
					                        allow play 127.0.0.1;
					
					                        hls on;
					                        hls_path /var/lib/osp/live-adapt;
					                        hls_nested on;
					                        hls_fragment 1;
					                        hls_playlist_length 30s;
					
					                        hls_fragment_naming system;
					
					                        record off;
					
					                        # Instruct clients to adjust resolution according to bandwidth
					                        hls_variant _480 BANDWIDTH=1200000; # Medium bitrate, SD resolution
					                        hls_variant _720 BANDWIDTH=2048000; # High bitrate, HD 720p resolution
					                        hls_variant _src BANDWIDTH=4096000; # Source bitrate, source resolution
					                }
					
					                application record {
					                        live on;
					
					                        allow publish 127.0.0.1;
					                        allow play 127.0.0.1;
					
					                        on_publish http://osp/auth-record;
					                        exec_push mkdir -m 764 /var/lib/osp/videos/$name;
					
					                        recorder all {
					                            record all;
					                            record_path /tmp;
					                            record_unique on;
					                            record_suffix _%Y%m%d_%H%M%S.flv;
					                            exec_record_done ${pkgs.bash}/bin/bash -c "${pkgs.ffmpeg}/bin/ffmpeg -y -i $path -codec copy -movflags +faststart /var/lib/osp/videos/$name/$basename.mp4 && rm $path";
					                            exec_record_done mv /var/lib/osp/stream-thumb/$name.png /var/lib/osp/videos/$name/$basename.png;
					                            exec_record_done mv /var/lib/osp/stream-thumb/$name.gif /var/lib/osp/videos/$name/$basename.gif;
					                            on_record_done http://osp/deauth-record;
					                        }
					                }
					
					                application live {
					                        live on;
					                        drop_idle_publisher 30s;
					                        allow publish 127.0.0.1;
					                        allow play all;
					
					                        on_play http://osp/playbackAuth;
					                }
					        }
					}
        '';
    };

    services.redis = {
      enable = true;
      appendFsync = "no";
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "osp" ];
      ensureUsers = [{
        name = "osp";
        ensurePermissions."DATABASE osp" = "ALL PRIVILEGES";
      }];
    };

    services.ejabberd = {
      enable = true;
      configFile = pkgs.substituteAll {
        name = "ejabberd.yml";
        src = ./ejabberd.yml;

        inherit (cfg) hostName;

        python = let
          penv = pkgs.python37.buildEnv.withPackages (p: with p; [ requests ]);
        in "${penv}/bin/python3.7";

        osp = pkgs.osp;
      };
    };
  };
}
