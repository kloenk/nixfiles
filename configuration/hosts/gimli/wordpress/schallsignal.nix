{ config, lib, pkgs, ... }:

let
in {
  services.wordpress.schallsignal = {
    database.name = "wp_schallsignal";
    database.tablePrefix = "YCfOImQp";

    themes = with pkgs.wordpressThemes; [
      twentyNineteen
      twentySeventeen
      twentyTwenty
      oceanWP
      trance
    ];
    plugins = with pkgs.wordpressPlugins; [
      kismet-antispam
      antispamBee
      backItUp

      podlove.publischer
      podlove.button
      podlove.player

      elementor
      wpforms
    ];
  };

  #systemd.services.wordpress-init-schallsignal.serviceConfig.User =
  #  lib.mkOverride 25 config.services.nginx.user;
  systemd.services.wordpress-init-schallsignal.serviceConfig.Group =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-schallsignal.settings."listen.owner" =
    lib.mkOverride 25 config.services.nginx.user;
  services.phpfpm.pools.wordpress-schallsignal.settings."group" =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-schallsignal.settings."listen.group" =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-schallsignal.group =
    lib.mkOverride 25 config.services.nginx.group;

  services.nginx.virtualHosts."schallsignal.wass-er.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      root = config.services.httpd.virtualHosts.schallsignal.documentRoot;
      extraConfig = ''
           index index.php;
           try_files $uri $uri/ /index.php?$args;
         '';
    };
    locations."~ \\.php$" = {
      root = config.services.httpd.virtualHosts.schallsignal.documentRoot;
      extraConfig = ''
           fastcgi_pass unix:${config.services.phpfpm.pools.wordpress-schallsignal.socket};
           fastcgi_index index.php;
           fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
           include ${config.services.nginx.package}/conf/fastcgi_params;
           include ${config.services.nginx.package}/conf/fastcgi.conf;
         '';
    };
  };

  services.nginx.virtualHosts."daten.wass-er.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/pod/" = {
      alias = "/var/lib/wordpress/daten/pod/";
      exatrConfig = ''
          add_header Referrer-Policy "no-referrer-when-downgrade" always;
          add_header Strict-Transport-Security $hsts_header always;
          add_header X-Content-Type-Options "nosniff";
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-Xss-Protection "1; mode=block";
          add_header Cache-Control "public";
      '';
    };
  };
}
