{ self, lib, pkgs, ... }:

{
  imports = [ ./zsh.nix ];

  home-manager.users.kloenk = {
    home.stateVersion = "23.11";
    manual.manpages.enable = false;

    programs.ssh = {
      enable = true;
      controlMaster = "auto";
      controlPersist = "5m";

      matchBlocks = let
        hostNames = (attrs:
          builtins.filter (name: (name != "defaults" && name != "ktest"))
          (builtins.attrNames attrs)) self.nixosConfigurations;
        matchBlocksForHosts = host: [
          {
            name = host;
            value = {
              hostname = "${host}.kloenk.de";
              port = 62954;
              forwardAgent = true;
            };
          }
          {
            name = "${host}-net";
            value = {
              hostname = "${host}.net.kloenk.de";
              port = 62954;
              forwardAgent = true;
            };
          }
        ];
        matchBlocks = builtins.listToAttrs
          (lib.flatten (map matchBlocksForHosts hostNames));
      in matchBlocks // {
        "*.kloenk.de" = {
          port = 62954;
          forwardAgent = true;
        };
        "*.net.kloenk.de" = {
          port = 62954;
          forwardAgent = true;
        };
        "cyberchaos.dev" = { port = 62954; };
      };
    };
  };
}
