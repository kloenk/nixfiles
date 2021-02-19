{ config, lib, pkgs, ... }:

let
in {
  petabyte.secrets."wp/crewkleidung.htaccess".owner = "nginx";

  services.wordpress.crewkleidung = {
    database.name = "wp_crewkleidung";
    #database.user = "wp_wass";

    themes = with pkgs.wordpressThemes; [
      twentyTwelf
      twentyFourteen
      twentyFifteen
      twentySixteen
      twentyNineteen
      twentyTwenty
    ];
    plugins = with pkgs; [
      wordpressPlugins.kismet-antispam
      wordpressPlugins.contactForm
      wordpressPlugins.backItUp
      wordpressPlugins.woocomerce
    ];
  };

  #systemd.services.wordpress-init-crewkleidung.serviceConfig.User =
  #  lib.mkOverride 25 config.services.nginx.user;
  systemd.services.wordpress-init-crewkleidung.serviceConfig.Group =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-crewkleidung.settings."listen.owner" =
    lib.mkOverride 25 config.services.nginx.user;
  services.phpfpm.pools.wordpress-crewkleidung.settings."group" =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-crewkleidung.settings."listen.group" =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-crewkleidung.group =
    lib.mkOverride 25 config.services.nginx.group;

  services.nginx.virtualHosts."crewkleidung.wass-er.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      root = config.services.httpd.virtualHosts.crewkleidung.documentRoot;
      extraConfig = ''
           auth_basic           "Bitte melde Dich an…";
           auth_basic_user_file ${config.petabyte.secrets."wp/crewkleidung.htaccess".path};
           index index.php;
           try_files $uri $uri/ /index.php?$args;
         '';
    };
    locations."~ \\.php$" = {
      root = config.services.httpd.virtualHosts.crewkleidung.documentRoot;
      extraConfig = ''
           auth_basic           "Bitte melde Dich an…";
           auth_basic_user_file ${config.petabyte.secrets."wp/crewkleidung.htaccess".path};
           fastcgi_pass unix:${config.services.phpfpm.pools.wordpress-crewkleidung.socket};
           fastcgi_index index.php;
           fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
           include ${config.services.nginx.package}/conf/fastcgi_params;
           include ${config.services.nginx.package}/conf/fastcgi.conf;
         '';
    };
    locations."/robots.txt".return = "200 \"User-agent: *\\nDisallow: /\\n\"";
  };
}
