{ config, lib, pkgs, ... }:

{
  fileSystems."/var/lib/gerrit" = {
    device = "/persist/data/gerrit";
    fsType = "none";
    options = [ "bind" ];
  };

  services.gerrit = {
    enable = true;
    serverId = "A530371C-74B2-49CF-87B1-C7F17F717E40";
    listenAddress = "127.0.0.1:8874";
    builtinPlugins = [ "hooks" "webhooks" ];
    settings = {
      gerrit.canonicalWebUrl = "https://gerrit.kloenk.dev/";
      #gerrit.basePath = "/persist/data/gitolite";
      gerrit.defaultBranch = "main";
      httpd.listenUrl = "proxy-https://127.0.0.1:8874/";
      auth.type = "HTTP";
      auth.loginUrl = "https://gerrit.kloenk.dev/login/";
    };
  };

  services.nginx.virtualHosts."gerrit.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8874";
      extraConfig = ''
        auth_basic "Gerrit login";
        auth_basic_user_file ${config.petabyte.secrets."gerrit/htaccess".path};
        proxy_set_header Authorization $http_authorization;
      '';
    };
    locations."/login" = {
      proxyPass = "http://127.0.0.1:8874";
      extraConfig = ''
        auth_basic "Gerrit login";
        auth_basic_user_file ${config.petabyte.secrets."gerrit/htaccess".path};
        proxy_set_header Authorization $http_authorization;
      '';
    };
  };

  petabyte.secrets."gerrit/htaccess".owner = "nginx";
}
