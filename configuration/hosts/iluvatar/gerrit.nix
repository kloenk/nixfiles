{ config, lib, pkgs, ... }:

let
  oauth = pkgs.fetchurl {
    url = "https://github.com/davido/gerrit-oauth-provider/releases/download/v3.1.3/gerrit-oauth-provider-gab09506.jar";
    sha256 = "ea50d6168393a668b2ee9282058ca7c3b0a1f94df7b501dfe46d071f1622917b";
    name = "oauth.jar";
  };
in {
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
    plugins = [ oauth ];
    settings = {
      gerrit.canonicalWebUrl = "https://gerrit.kloenk.dev/";
      #gerrit.basePath = "/persist/data/gitolite";
      gerrit.defaultBranch = "main";
      httpd.listenUrl = "proxy-https://127.0.0.1:8874/";

      auth = {
        type = "OAUTH";
        #loginUrl = "https://gerrit.kloenk.dev/login/";
        cookieSecure = true;
        gitBasicAuthPolicy = "HTTP";
      };
      "plugin \"gerrit-oauth-provider-github-oauth\"" = {
        "root-url" = "https://github.com/";
        "client-id" = "acdf340dd53685441d35";
      };
    };
  };
  systemd.services.gerrit.serviceConfig.ExecStartPre = let 
     secure = pkgs.writeShellScript "install-sercure-gerrit-config" ''
      # install the secret config
      cat ${config.petabyte.secrets."gerrit/secure.config".path} > etc/secure.config
    '';
    preStart = pkgs.writeShellScript "gerrit-start" config.systemd.services.gerrit.preStart;
  in lib.mkForce [ preStart "+${secure}"  ];

  services.nginx.virtualHosts."gerrit.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8874";
      /*extraConfig = ''
        auth_basic "Gerrit login";
        auth_basic_user_file ${config.petabyte.secrets."gerrit/htaccess".path};
        proxy_set_header Authorization $http_authorization;
      '';*/
    };
    locations."/login/" = {
      proxyPass = "http://127.0.0.1:8874";
      extraConfig = ''
        auth_basic "Gerrit login";
        auth_basic_user_file ${config.petabyte.secrets."gerrit/htaccess".path};
        proxy_set_header Authorization $http_authorization;
      '';
    };
  };

  petabyte.secrets."gerrit/htaccess".owner = "nginx";
  petabyte.secrets."gerrit/secure.config".owner = "root";
}
