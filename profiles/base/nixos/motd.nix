{ pkgs, lib, config, ... }:
let
  colors = {
    varda = 92;
    gimli = 94;
    thrain = 96;
    elrond = 97;

    gloin = 98;

    moodle-usee = 31;
  };
in {
  users.motd = let
    welcome = "Welcome${
        if config.networking.domain != null then
          " to ${config.networking.domain}"
        else
          ""
      }";
    hostname = "[${
        builtins.toString (colors.${config.networking.hostName} or 0)
      }m${config.networking.hostName}[0m";
  in ''
    [92m${welcome}.[0m This is ${hostname}.
    We hope you have a good stay. Please don't forget to drink some water today!
  '';
}
