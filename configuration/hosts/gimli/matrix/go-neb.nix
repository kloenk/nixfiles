{ lib, pkgs, config, ... }:

{
  services.nginx.virtualHosts."api.matrix.kloenk.dev" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://${config.services.go-neb.bindAddress}";
  };

  services.go-neb = {
    enable = true;
    baseUrl = "api.matrix.kloenk.dev";
    bindAddress = "localhost:4050";
    secretFile = config.sops.secrets."matrix/api/secrets";
    config = {
      clients = [
        {
          UserID = "@slackapi:kloenk.dev";
          AccessToken = "$SLACKAPI_ACCESS_TOKEN";
          DeviceID = "gimli";
          HomeserverURL = "http://localhost:8008";
          Sync = true;
          AutoJoinRooms = false;
          DisplayName = "Slack API user";
          AcceptVerificationFromUsers = [ "^@kloenk:petabyte.dev" ];
        }
      ];
      services = [{
        ID = "slackapi_service";
        Type = "slackapi";
        UserID = "@slackapi:kloenk.dev";
        Config = {
          Hooks = {
            "exneuland" = {
              RoomID = "!ccJiAMVLHScttowClJ:petabyte.dev";
              MessageType = "m.text";
            };
          };
        };
      }];
    };
  };

  sops.secrets."matrix/api/secrets".owner = "root";
  systemd.services.go-neb.serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
}