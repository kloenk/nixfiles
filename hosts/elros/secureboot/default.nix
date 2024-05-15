{ lib, config, pkgs, ... }:

let keys = [ "PK" "KEK" "db" ];
in {
  imports = [ ../../../profiles/secureboot.nix ];

  environment.etc.secureboot.source = lib.mkForce (pkgs.linkFarm "secureboot"
    ([{
      name = "GUID";
      path = builtins.toFile "GUID" "b2374e31-0b1b-4259-8030-1edd3348895c";
    }] ++ (lib.flatten (map (key: [
      {
        name = "keys/${key}/${key}.pem";
        path = ./. + "/${key}.crt";
      }
      {
        name = "keys/${key}/${key}.key";
        path = config.sops.secrets."secureboot/${key}".path;
      }
    ]) keys))));

  sops.secrets = lib.listToAttrs (map (key: {
    name = "secureboot/${key}";
    value.owner = "root";
  }) keys);
}
