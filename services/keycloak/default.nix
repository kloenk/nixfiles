{ config, lib, pkgs, ... }:

let
  pluginRestrictClientAuth = pkgs.stdenv.mkDerivation rec {
    pname = "keycloak-restrict-client-auth";
    version = "23.0.0";

    src = pkgs.fetchurl {
      url =
        "https://github.com/sventorben/keycloak-restrict-client-auth/releases/download/v${version}/keycloak-restrict-client-auth.jar";
      sha256 = "sha256-JwY1fByu8HOhRZ1KCZCN+0Xv06XcfXycc6pBvm9OQqE=";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      install "$src" "$out"
    '';
  };
in {
  fileSystems."/var/lib/private/keycloak" = {
    device = "/persist/data/keycloak";
    fsType = "none";
    options = [ "bind" ];
  };

  services.keycloak = {
    enable = true;
    package = pkgs.keycloak.override {
      extraFeatures = [ "account3" "declarative-user-profile" ];
      disabledFeatures = [ "kerberos" ];
    };
    database.passwordFile = config.sops.secrets."keycloak/db/password".path;
    initialAdminPassword = "foobar";
    plugins = [ pluginRestrictClientAuth ];
    settings = {
      http-host = "127.0.0.1";
      http-port = config.k.ports.keycloak;
      hostname = "auth.kloenk.dev";
      proxy = "edge";
    };
  };

  services.nginx.virtualHosts."auth.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.k.ports.keycloak}";
      extraConfig = ''
        proxy_buffer_size          128k;
        proxy_buffers              4 256k;
        proxy_busy_buffers_size    256k;
      '';
    };
    locations."= /" = {
      return = "301 https://auth.kloenk.dev/realms/kloenk/account/";
    };
  };

  sops.secrets."keycloak/db/password".owner = "root";
}
