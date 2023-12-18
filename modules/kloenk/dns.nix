{ lib, config, ... }:

let inherit (lib) mkOption types mkIf;
in {
  options = {
    k.dns = {
      ipv4 = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      ipv6 = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      public = lib.mkEnableOption "public reachable server";
    };
  };

  config = {
    networking.domains = {
      baseDomains = lib.listToAttrs (map (name: {
        name = name;
        value = {
          a.data = config.k.dns.ipv4;
          aaaa.data = config.k.dns.ipv6;
          /* caa.data = [
               {
                 flags = 0;
                 tag = "issue";
                 value = "letsencrypt.org";
               }
             ];
          */
        };
      }) [
        "kloenk.de"
        "kloenk.eu"
        "kloenk.dev"
        "p3tr1ch0rr.de"
        "sysbadge.dev"
      ]);
      subDomains = mkIf config.k.dns.public (lib.listToAttrs (map (name: {
        name = "${config.networking.hostName}.${name}";
        value = { };
      }) [ "kloenk.de" "kloenk.eu" "kloenk.dev" ]));
    };
  };
}
