{ config, lib, pkgs, ... }:

let
  hitchcock = pkgs.stdenv.mkDerivation {
    name = "hitchcock";

    src = pkgs.fetchurl {
      url = "https://downloads.wordpress.org/theme/hitchcock.2.0.2.zip";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };

    buildInputs = with pkgs; [ unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  };
in {
  services.wordpress.trudeltiere = {
    database.name = "db656104473";
    database.tablePrefix = "tIUcycAB";

    themes = [
      hitchcock
    ];
  };

  #systemd.services.wordpress-init-trudeltiere.serviceConfig.User =
  #  lib.mkOverride 25 config.services.nginx.user;
  systemd.services.wordpress-init-trudeltiere.serviceConfig.Group =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-trudeltiere.settings."listen.owner" =
    lib.mkOverride 25 config.services.nginx.user;
  services.phpfpm.pools.wordpress-trudeltiere.settings."group" =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-trudeltiere.settings."listen.group" =
    lib.mkOverride 25 config.services.nginx.group;
  services.phpfpm.pools.wordpress-trudeltiere.group =
    lib.mkOverride 25 config.services.nginx.group;

  services.nginx.virtualHosts."trudeltiere.de" = {
    #enableACME = true;
    #forceSSL = true;
    locations."/" = {
      root = config.services.httpd.virtualHosts.trudeltiere.documentRoot;
      extraConfig = ''
           index index.php;
           try_files $uri $uri/ /index.php?$args;
         '';
    };
    locations."~ \\.php$" = {
      root = config.services.httpd.virtualHosts.trudeltiere.documentRoot;
      extraConfig = ''
           fastcgi_pass unix:${config.services.phpfpm.pools.wordpress-trudeltiere.socket};
           fastcgi_index index.php;
           fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
           include ${config.services.nginx.package}/conf/fastcgi_params;
           include ${config.services.nginx.package}/conf/fastcgi.conf;
         '';
    };
  };
}