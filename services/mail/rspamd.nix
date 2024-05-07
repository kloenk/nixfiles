{ config, ... }:

{
  services.nginx.virtualHosts."rspamd.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://unix:/run/rspamd/worker-controller.sock";

      # disable for auth as done via vouch
      recommendedProxySettings = false;
      extraConfig = ''
        proxy_set_header X-Forwarded-For "";
      '';
    };
  };

  services.vouch-proxy = {
    enable = true;
    servers."rspamd.kloenk.de" = {
      clientId = "rspamd";
      port = 12303;
      environmentFiles = [ config.sops.secrets."rspamd/vouch_proxy_env".path ];
    };
  };

  sops.secrets."rspamd/vouch_proxy_env".owner = "root";
}
