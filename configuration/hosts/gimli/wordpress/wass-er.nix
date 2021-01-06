{ config, lib, pkgs, ... }:

let
in {
  services.wordpress.wass-er = {
    database.name = "wp_wass";
    database.user = "wp_wass";
    database.tablePrefix = "tIUcycAB";

    themes = [
    ];
    plugins = with pkgs; [
      wordpressPlugins.kismet-antispam
      wordpressPlugins.contactForm
      wordpressPlugins.backItUp
    ];
  };

  #systemd.services.wordpress-init-wass-er.serviceConfig.User =
  #  lib.mkOverride 25 config.services.nginx.user;
  systemd.services.wordpress-init-wass-er.serviceConfig.Group =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-wass-er.settings."listen.owner" =
    lib.mkOverride 25 config.services.nginx.user;
  services.phpfpm.pools.wordpress-wass-er.settings."group" =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-wass-er.settings."listen.group" =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-wass-er.group =
    lib.mkOverride 25 config.services.nginx.group;

  services.nginx.virtualHosts."wass-er.com" = {
    #enableACME = true;
    #forceSSL = true;
    locations."/" = {
      root = config.services.httpd.virtualHosts.wass-er.documentRoot;
      extraConfig = ''
           index index.php;
           try_files $uri $uri/ /index.php?$args;
         '';
    };
    locations."~ \\.php$" = {
      root = config.services.httpd.virtualHosts.wass-er.documentRoot;
      extraConfig = ''
           fastcgi_pass unix:${config.services.phpfpm.pools.wordpress-wass-er.socket};
           fastcgi_index index.php;
           fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
           include ${config.services.nginx.package}/conf/fastcgi_params;
           include ${config.services.nginx.package}/conf/fastcgi.conf;
         '';
    };
  };
}
