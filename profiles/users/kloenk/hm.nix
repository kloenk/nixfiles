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

    programs.hyfetch = {
      enable = true;
      settings = {
        args = null;
        backend = "neofetch";
        color_align = {
          custom_colors = [ ];
          fore_back = null;
          mode = "horizontal";
        };
        distro = null;
        light_dark = "dark";
        lightness = 0.65;
        mode = "rgb";
        preset = "transgender";
        pride_month_disable = false;
        pride_month_shown = [ ];
      };
    };

    accounts.email.accounts."finn@kloenk.dev" = {
      address = "finn@kloenk.dev";
      primary = true;
      aliases = [
        "finn.behrens@kloenk.de"
        "behrens.finn@kloenk.de"
        "info@kloenk.de"
        "me@kloenk.de"
        "finn@kloenk.de"
        "applications@kloenk.de"
        "applications@kloenk.dev"

        "finn.behrens@kloenk.dev"
        "behrens.finn@kloenk.dev"
        "info@kloenk.dev"
        "me@kloenk.dev"

        "info@sysbadge.dev"
      ];
      smtp = { host = "gimli.kloenk.de"; };
    };
  };
}
