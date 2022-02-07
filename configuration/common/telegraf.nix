{ lib, pkgs, config, ... }:

{
  services.telegraf = {
   enable = true;
   extraConfig = {
     outputs.influxdb = {
       database = "telegraf";
       url = [ "https://influx.kloenk.dev" ];
     };
   };
   environmentFiles = [ config.sops.secrets."monitoring/telegraf/config".path ];
  };

  sops.secrets."monitoring/telegraf/config".owner = "root";
}