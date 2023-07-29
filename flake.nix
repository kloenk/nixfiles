{
  description = "Kloenk's NixOS configuration";

  inputs.nixpkgs = {
    type = "github";
    owner = "nixos";
    repo = "nixpkgs";
    #    ref = "from-unstable";
  };

  inputs.nix = {
    type = "github";
    owner = "nixos";
    repo = "nix";
    #inputs.nixpkgs.follows = "/nixpkgs"; # broken
  };

  inputs.moodlepkgs = {
    type = "github";
    owner = "kloenk";
    repo = "moodlepkgs";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.mail-server = {
    type = "gitlab";
    owner = "simple-nixos-mailserver";
    repo = "nixos-mailserver";
    ref = "master";
  };

  inputs.kloenk-www = {
    type = "gitlab";
    owner = "kloenk";
    repo = "www";
    host = "cyberchaos.dev";
  };

  inputs.dns = {
    type = "github";
    owner = "kloenk";
    #owner = "kirelagin";
    repo = "nix-dns";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  inputs.darwin = {
    type = "github";
    owner = "lnl7";
    repo = "nix-darwin";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.vika = {
    type = "sourcehut";
    owner = "~vikanezrimaya";
    repo = "nix-flake";
  };

  inputs.colmena = {
    url = "github:zhaofengli/colmena";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.jlly = {
    url = "github:kloenk/jlly_bot";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.fleet_bot = {
    url = "github:fleetyards/fleet_bot";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.p3tr = {
    url = "github:kloenk/p3tr";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.sysbadge = {
    url = "gitlab:kloenk/sysbadge?host=cyberchaos.dev";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.devenv.url = "github:cachix/devenv";

  inputs.nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  inputs.nix-minecraft.inputs.nixpkgs.follows = "/nixpkgs";

  outputs = inputs@{ self, nixpkgs, nix, moodlepkgs, mail-server, kloenk-www
    , dns, darwin, sops-nix, vika, colmena, jlly, fleet_bot, p3tr, sysbadge
    , devenv, ... }:
    let
      overlayCombined = system: [
        #nix.overlays.default
        #(final: prev: { nix = nix.packages.${system}.nix; })
        #home-manager.overlay
        self.overlays.kloenk
        moodlepkgs.overlay
        kloenk-www.overlay
        inputs.nix-minecraft.overlay
        colmena.overlay
        jlly.overlays.default
        fleet_bot.overlays.default
        p3tr.overlays.default
        sysbadge.overlays.sysbadge
      ];

      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # Memoize nixpkgs for different platforms for efficiency.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = (overlayCombined system);
        });

      darwinHosts = nixpkgs.lib.filterAttrs
        (name: host: if host ? darwin then host.darwin else false)
        (import ./configuration/darwin { });

      # patche modules
      /* patchModule = system: {
           disabledModules =
             [
               "services/games/minecraft-server.nix"
               "tasks/auto-upgrade.nix"
               "services/web-apps/wordpress.nix"
               "services/web-apps/restya-board.nix"
             ];
           imports = [
           ];
           nixpkgs.overlays = [ (overlays system) nix.overlays.default ];
         };
      */

    in {
      overlays.kloenk = final: prev:
        (import ./pkgs/overlay.nix inputs final prev);
      overlays.default = self.overlays.kloenk;

      legacyPackages = forAllSystems (system: nixpkgsFor.${system});

      packages =
        forAllSystems (system: { inherit (nixpkgsFor.${system}) wallpapers; });

      nixosConfigurations =
        let hive = inputs.colmena.lib.makeHive self.outputs.colmena;
        in hive.nodes;

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = (overlayCombined "x86_64-linux");
          };
          #allowApplyAll = false;

          specialArgs.inputs = inputs;
        };

        defaults = { pkgs, ... }: {
          disabledModules = [
            "services/games/minecraft-server.nix"
            "services/web-apps/wordpress.nix"
          ];
          imports = [
            ./configuration/common
            #home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            inputs.nix-minecraft.nixosModules.minecraft-servers
            self.nixosModules.matrix-sliding-sync
            jlly.nixosModules.default
            fleet_bot.nixosModules.default
            p3tr.nixosModules.default

            self.nixosModules.nftables
            self.nixosModules.deluge2
            #self.nixosModules.firefox
            self.nixosModules.wordpress
            self.nixosModules.transient

            vika.nixosModules.colorfulMotd
            vika.nixosModules.secureSSHClient
          ];
          # disable home-manager manpage (breaks hydra see https://github.com/rycee/home-manager/issues/1262)
          #home-manager.users.kloenk.manual.manpages.enable = false;

          environment.systemPackages = [ # pkgs.colmena
          ];

          #nix.channel.enable = false;

          deployment = {
            buildOnTarget = true;
            allowLocalDeployment = true;
            targetPort = 62954;
            targetUser = "kloenk";
          };
        };

        # DUS 6
        iluvatar = { pkgs, nodes, ... }: {
          deployment = {
            targetHost = "iluvatar.kloenk.dev";
            tags = [ "hetzner" "remote" ];
          };

          imports = [
            ./configuration/hosts/iluvatar
            mail-server.nixosModules.mailserver
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };
        # USee
        moodle-usee = { pkgs, nodes, ... }: {
          deployment.targetHost = "moodle-usee.kloenk.dev";
          deployment.tags = [ "usee" "remote" ];

          imports = [
            ./configuration/hosts/moodle-usee
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };

        # Pony
        thrain = { pkgs, nodes, ... }: {
          deployment.targetHost = "192.168.178.248";
          deployment.tags = [ "pony" "local" ];

          imports = [ ./configuration/hosts/thrain ];

          # ZFS kernel
          nixpkgs.config.allowBroken = true;
        };
        elrond = { pkgs, nodes, ... }: {
          deployment.targetHost = "192.168.178.247";
          deployment.tags = [ "pony" "local" ];

          imports = [
            ./configuration/hosts/elrond
            #vika.nixosModules.gnome
            vika.nixosModules.bgrtSplash
          ];
          users.users.kloenk.packages = [ inputs.nixpkgs.legacyPackages.x86_64-linux.nil ];
        };
        #durin = { pkgs, nodes, ... }: {
        #  deployment.targetHost = "durin.fritz.box";
        #  deployment.tags = [ "pony" "local" ];

        #  imports = [ ./configuration/hosts/durin ];
        #};
      };

      nixosModules = {
        ferm2 = import ./modules/ferm2;
        deluge2 = import ./modules/deluge.nix;
        autoUpgrade = import ./modules/upgrade;
        #firefox = import ./modules/firefox;
        #secrets = import ./modules/secrets;
        transient = import ./modules/transient;
        nftables = import ./modules/nftables;

        restya-board = import ./modules/restya-board;

        wordpress = import ./modules/wordpress.nix;
        matrix-sliding-sync = import ./modules/matrix-sliding-sync;
      };

      darwinModules = { epmd = import ./modules/darwin/epmd; };

      darwinConfigurations = (nixpkgs.lib.mapAttrs (name: host:
        (darwin.lib.darwinSystem {
          system = host.system;
          modules = [
            {
              nixpkgs.overlays = (overlayCombined host.system);
            }
            #home-manager.nixosModules.home-manager
            (import (./configuration + "/darwin/${name}/darwin.nix"))
            self.darwinModules.epmd
          ];
        })) darwinHosts);

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          devenv = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              ({ pkgs, ... }: { packages = [ pkgs.colmena ]; })
              {
                languages.nix.enable = true;

                pre-commit.hooks.actionlint.enable = true;
                pre-commit.hooks.nixfmt.enable = true;
              }
            ];
          };
          default = self.devShells.${system}.devenv;
        });

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt);

      checks = forAllSystems
        (system: { devenv_ci = self.devShells.${system}.devenv.ci; });
    };
  nixConfig = {
    extra-substituters = [ "https://kloenk.cachix.org" ];
    extra-trusted-public-keys =
      [ "kloenk.cachix.org-1:k52XSkCLOxnmEnjzuedYOzf0MtQp8P3epqOmAlCHYpc=" ];
  };
}
