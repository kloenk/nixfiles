{ config, pkgs, ... }:

{
  fileSystems."/var/lib/mysql" = {
    device = "/persist/data/mysql";
    fsType = "none";
    options = [ "bind" ];
  };
  fileSystems."/var/lib/snipe-it" = {
    device = "/persist/data/snipe-it";
    fsType = "none";
    options = [ "bind" ];
  };

  services.snipe-it = {
    enable = true;
    appKeyFile = config.sops.secrets."snipe-it/appkey".path;
    hostName = "assets.kloenk.dev";
    mail = {
      driver = "smtp";
      host = "gimli.kloenk.de";
      port = 587;
      user = "no-reply@kloenk.dev";
      passwordFile = config.sops.secrets."snipe-it/mail-password".path;
      encryption = "tls";
      from.address = "no-reply@kloenk.dev";
    };
    nginx = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
    };
    config = {
      DB_SOCKET = "/var/run/mysqld/mysqld.sock";
      ENABLE_HSTS = true;
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "snipeit" ];
    ensureUsers = [{
      name = "snipeit";
      ensurePermissions = { "snipeit.*" = "ALL PRIVILEGES"; };
    }];
  };

  sops.secrets."snipe-it/appkey".owner = "snipeit";
  sops.secrets."snipe-it/mail-password".owner = "snipeit";
}
