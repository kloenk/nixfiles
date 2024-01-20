{ lib, config, ... }:

let inherit (lib) mkOption types;
in {
  options.k.ports = mkOption {
    type = types.attrsOf (types.either types.port (types.attrsOf types.port));
  };
}
