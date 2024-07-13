{ lib, pkgs, config, inputs, ... }:

let
  inherit (lib) types mkEnableOption mkOption mkIf;

  cfg = config.k.secureboot;

  pkiBundle = pkgs.linkFarm "secureboot-keys" ([{
    name = "GUID";
    path = builtins.toFile "GUID" cfg.guid;
  }] ++ (lib.flatten (lib.mapAttrsToList (name: key: [
    {
      name = "keys/${name}/${name}.pem";
      path =
        if builtins.isPath key then key else builtins.toFile "${name}.pem" key;
    }
    {
      name = "keys/${name}/${name}.key";
      path = config.sops.secrets."secureboot/${name}".path;
    }
  ]) cfg.keys)));
in {
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.k.secureboot = {
    enable = mkEnableOption "Secureboot";

    guid = mkOption { type = types.str; };

    keys =
      mkOption { type = types.attrsOf (types.either types.str types.path); };
  };

  config = mkIf cfg.enable {
    # Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time. So we force it to false
    # for now.
    boot.loader.systemd-boot.enable = lib.mkForce false;

    environment.etc."secureboot".source = lib.mkDefault pkiBundle;

    boot.lanzaboote = {
      enable = true;
      inherit pkiBundle;
    };

    sops.secrets = lib.mapAttrs' (name: _value: {
      name = "secureboot/${name}";
      value.owner = "root";
    }) cfg.keys;
  };
}
