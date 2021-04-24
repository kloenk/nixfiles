{ pkgs, lib, config, ... }:

let
  bbb = pkgs.moodle-utils.buildMoodlePlugin {
    name = "bigbluebuttonbn";
    src = pkgs.fetchzip {
      name = "bbb-moodle-plugin";
      url =
        "https://moodle.org/plugins/download.php/23293/mod_bigbluebuttonbn_moodle310_2019042011.zip";
      sha256 =
        "12aclcjm3wq8lz7ks3nk1pb0is2a2wljy7db6qjc2v4hjnybhrlq";
      extraPostFetch = ''
        echo fix perm: $out
        chmod a-w -R $out
      '';
    };
    pluginType = "mod";
  };
  tiles = pkgs.moodle-utils.buildMoodlePlugin {
    name = "tiles";
    src = pkgs.fetchzip {
      name = "tiles";
      url =
        "https://moodle.org/plugins/download.php/23359/format_tiles_moodle310_2020080613.zip";
      sha256 =
        "1vya5j7nhyb1xmkp3ia26zb7k2w0z8axpqr2scgbd2kmb8lqgccq";
      extraPostFetch = ''
        echo fix perm: $out
        chmod a-w -R $out
      '';
    };
    pluginType = "course";
  };
  sharing_cart = pkgs.moodle-utils.buildMoodlePlugin {
    name = "sharing_cart";
    src = pkgs.fetchzip {
      name = "sharing_cart";
      url =
        "https://moodle.org/plugins/download.php/23686/block_sharing_cart_moodle310_2021031300.zip";
      sha256 =
        "1g1hvjllkxh5q7vzh0jmf257id51dc88laf6l2mqvwwz5wq4y303";
      extraPostFetch = ''
        echo fix perm: $out
        chmod a-w -R $out
      '';
    };
    pluginType = "block";
  };
  scheduler = pkgs.moodle-utils.buildMoodlePlugin {
    name = "scheduler";
    src = pkgs.fetchzip {
      name = "scheduler";
      url =
        "https://moodle.org/plugins/download.php/20738/mod_scheduler_moodle39_2019120200.zip";
      sha256 =
        "0n5qbqcb3j631j6q7fw0anffp7hgc2c7mg8z3i5z6fpi1pc20sjg";
      extraPostFetch = ''
        echo fix perm: $out
        chmod a-w -R $out
      '';
    };
    pluginType = "mod";
  };
in {
  services.moodle = {
    enable = true;
    initialPassword = "foobar123";
    package = pkgs.moodle.override { plugins = [ bbb tiles sharing_cart scheduler ]; };
    virtualHost = {
      adminAddr = "holger.behrens@unterbachersee.de";
      enableACME = true;
      forceSSL = true;
      hostName = "segelschule.unterbachersee.de";
    };
    extraConfig = ''
      $CFG->xsendfile = 'X-Accel-Redirect';
      $CFG->xsendfilealiases = array(
        '/dataroot/' => $CFG->dataroot
      );
    '';
    /*poolConfig = {
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.max_spare_servers" = 4;
      "pm.min_spare_servers" = 2;
      "pm.start_servers" = 2;
    };*/
  };

  services.nginx.virtualHosts."segelschule.unterbachersee.de" = {
    extraConfig = ''
      index index.php index.html;
    '';
    enableACME = true;
    forceSSL = true;
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

  /*systemd.services.mysql.postStart = (lib.mkBefore ''
    sleep 30s
    export USER=root
  '');*/

  # MARK: DISABLE httpd
  services.httpd.enable = lib.mkOverride 25 false; # No thanks, I choose life
  services.httpd.group = config.services.nginx.group;
}
