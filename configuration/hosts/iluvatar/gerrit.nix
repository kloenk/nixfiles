{ config, lib, pkgs, ... }:

{
  services.gerrit = {
    enable = true;
    serverId = "A530371C-74B2-49CF-87B1-C7F17F717E40";
    listenAddress = "127.0.0.1:8874";
    builtinPlugins = [ "hooks" "webhooks" ];
    settings = {
      gerrit.canonicalWebUrl = "https://gerrit.kloenk.dev/";
      gerrit.basePath = "/persist/data/gitolite";
      gerrit.defaultBranch = "main";
      httpd.listenUrl = "proxy-https://127.0.0.1:8874";
    };
  };

  services.nginx.virtualHosts."gerrit.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."^~ /r/".proxyPass = "http://127.0.0.1:8874";
  };
}
