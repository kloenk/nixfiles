{ config, lib, pkgs, ... }:

{
  fileSystems."/var/lib/moodle" = {
    device = "/persist/data/moodle";
    fsType = "none";
    options = [ "bind" ];
  };

  services.moodle = {
    enable = true;
    initialPassword = "foobar123";
    package = pkgs.moodle.override { plugins = [ ]; };
    virtualHost = {
      adminAddr = "holger@wass-er.com";
      enableACME = true;
      forceSSL = true;
      hostName = "moodle.wass-er.com";
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

  services.nginx.virtualHosts."moodle.wass-er.com" = {
    enableAMCE = true;
    forceSSL = true;
    locations."~ [^/]\\.php(/|$)" = {
      root = "${config.services.moodle.package}/share/moodle";
         #fastcgi_split_path_info  ^(.+\.php)(.*)$;
      extraConfig = ''
         fastcgi_index            index.php;
         fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
         fastcgi_pass             ${config.services.phpfpm.pools.moodle.socket};
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

  services.phpfpm.phpOptions = ''
    upload_max_filesize = 8192M
    post_max_size = 9000M
  '';
}
