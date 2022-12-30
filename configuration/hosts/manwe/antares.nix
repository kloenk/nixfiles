{ config, ... }:

{
    services.postgresql.ensureDatabases = [ "antares" ];
    services.postgresql.ensureUsers = [{
      name = "antares";
      ensurePermissions."DATABASE antares" = "ALL PRIVILEGES";
    }];

    users = {
      users."antares" = {
        description = "antares user";
        group = "antares";
        isSystemUser = true;
      };
      groups."antares" = { };
    };
}