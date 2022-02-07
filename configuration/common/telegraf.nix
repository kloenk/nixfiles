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
  };
}