{ pkgs, lib, config, ... }:

{
  services.moodle = {
    enable = true;
    initialPassword = "foobar123";
    package = pkgs.moodle.override {
      plugins = with pkgs.moodlePackages; [ # bigbluebuttonbn
        tiles
        sharing_cart
        scheduler
        lightboxgallery
      ];
    };
    virtualHost = {
      adminAddr = "holger.behrens@unterbachersee.de";
      enableACME = true;
      forceSSL = true;
      hostName = "segelschule.unterbachersee.de";
    };
    database = { type = "pgsql"; };
    extraConfig = ''
      $CFG->xsendfile = 'X-Accel-Redirect';
      $CFG->xsendfilealiases = array(
        '/dataroot/' => $CFG->dataroot
      );
    '';
    /* poolConfig = {
         "pm" = "dynamic";
         "pm.max_children" = 32;
         "pm.max_requests" = 500;
         "pm.max_spare_servers" = 4;
         "pm.min_spare_servers" = 2;
         "pm.start_servers" = 2;
       };
    */
  };

  services.nginx.virtualHosts."segelschule.unterbachersee.de" = {
    extraConfig = ''
      rewrite ^/(.*\.php)(/)(.*)$ /$1?file=/$3 last;
      fastcgi_intercept_errors on;
      client_max_body_size 8G;
    '';
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      index = "index.php index.html index.htm";
      tryFiles = "$uri $uri/ /index.php";
    };
    root = "${config.services.moodle.package}/share/moodle";
    locations."~ [^/]\\.php(/|$)" = {
      root = "${config.services.moodle.package}/share/moodle";
      #fastcgi_split_path_info  ^(.+\.php)(.*)$;
      extraConfig = ''
        fastcgi_index            index.php;
        fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass             unix:${config.services.phpfpm.pools.moodle.socket};
        include ${config.services.nginx.package}/conf/fastcgi_params;
        include ${config.services.nginx.package}/conf/fastcgi.conf;
      '';
    };
    locations."/how-to/" = {
      alias = "/var/lib/moodle/how-to/";
      index = "index.html index.mp4";
    };
    locations."/infoabend/" = {
      alias = "/var/lib/moodle/infoabend/";
      index = "index.html index.mp4";
    };
    locations."/dataroot/" = {
      alias = "/var/lib/moodle/";
      extraConfig = ''
        internal;
      '';
    };
  };

  services.phpfpm.pools.moodle = {
    user = lib.mkForce "moodle";
    settings."security.limit_extensions" = ".php";
  };
  services.httpd.user = lib.mkForce "nginx";

  services.phpfpm.phpOptions = ''
    upload_max_filesize = 8192M
    post_max_size = 9000M
  '';

  /* systemd.services.mysql.postStart = (lib.mkBefore ''
       sleep 30s
       export USER=root
     '');
  */

  # fix moodle bug: https://tracker.moodle.org/browse/MDL-72131
  services.mysql.settings.mysqld.innodb_read_only_compressed = false;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    ensureDatabases = [ "moodle" ];
    ensureUsers = [{
      name = "moodle";
      ensurePermissions."DATABASE moodle" = "ALL PRIVILEGES";
    }];
  };

  # de locales
  i18n.supportedLocales = [ "de_DE.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

  # MARK: DISABLE httpd
  services.httpd.enable = lib.mkOverride 25 false; # No thanks, I choose life
  services.httpd.group = config.services.nginx.group;
}
