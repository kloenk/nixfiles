{ pkgs, lib, ... }:

{
  fileSystems."/var/lib/postgresql" = {
    device = "/persist/data/postgresql";
    fsType = "none";
    options = [ "bind" ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
  };

  # telegraf monitoring
  services.telegraf.extraConfig.inputs = {
    postgresql.address = "host=/run/postgresql user=telegraf database=postgres";
    postgresql_extensible = {
      address = "host=/run/postgresql user=telegraf database=postgres";
      query = [{
        sqlquery =
          "SELECT datname, state,count(datname) FROM pg_catalog.pg_stat_activity GROUP BY datname,state";
        measurement = "pg_stat_activity";
      }];

    };
  };
  services.postgresql.ensureUsers = [{ name = "telegraf"; }];
  systemd.services.postgresql.postStart = ''
    $PSQL -tAc 'GRANT pg_read_all_stats TO telegraf' -d postgres
  '';
  # TODO:
  # services.postgresqlBackup.enable = true;
}
