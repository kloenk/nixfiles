{ config, lib, pkgs, ... }:

{
  fileSystems."/var/lib/netbox" = {
    device = "/persist/data/netbox";
    fsType = "none";
    options = [ "bind" ];
  };

  services.netbox = {
    enable = true;
    package = pkgs.netbox_3_7;
    secretKeyFile = config.sops.secrets."netbox/secret_key".path;
    extraConfig = ''
      REMOTE_AUTH_ENABLED = True;
      REMOTE_AUTH_HEADER = 'HTTP_X_AUTH_REMOTE_USER';
      REMOTE_AUTH_AUTO_CREATE_USER = True;
    '';
    port = config.k.ports.netbox;
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "netbox" ];
    ensureUsers = [{
      name = "netbox";
      ensureDBOwnership = true;
    }];
  };

  services.nginx.virtualHosts."netbox.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.k.ports.netbox}";
      proxyWebsockets = true;
      extraConfig = ''
        auth_request_set $auth_resp_x_vouch_email $upstream_http_x_vouch_user;
        auth_request_set $auth_resp_x_vouch_username $upstream_http_x_vouch_idp_claims_preferred_username;
        proxy_set_header X-Auth-Remote-User $auth_resp_x_vouch_username;
      '';
    };
    locations."/static/".root = "/var/lib/netbox";
  };
  users.users.nginx.extraGroups = [ "netbox" ];

  services.vouch-proxy = {
    enable = true;
    servers."netbox.kloenk.de" = {
      clientId = "netbox";
      port = 12302;
      environmentFiles = [ config.sops.secrets."netbox/vouch_proxy_env".path ];
    };
  };

  sops.secrets."netbox/secret_key".owner = "netbox";
  sops.secrets."netbox/vouch_proxy_env".owner = "root";
}
