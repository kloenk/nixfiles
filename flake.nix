{
  description = "Kloenk's NixOS configuration";

  inputs.nixpkgs = {
    type = "github";
    owner = "nixos";
    repo = "nixpkgs";
    #    ref = "from-unstable";
  };

  inputs.nixpkgs-nrf = {
    type = "github";
    owner = "nixos";
    repo = "nixpkgs";
    ref = "nixos-23.05";
  };

  inputs.lix = {
    url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
    flake = false;
  };

  inputs.lix-module = {
    url =
      "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.lix.follows = "lix";
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
    owner = "kirelagin";
    repo = "dns.nix";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.darwin = {
    type = "github";
    owner = "lnl7";
    repo = "nix-darwin";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.mac-app-util = {
    url = "github:hraban/mac-app-util";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote/master";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  /* inputs.leona = {
       url = "gitlab:leona/nixfiles?host=cyberchaos.dev";
       inputs.nixpkgs.follows = "/nixpkgs";
       inputs.mailserver.follows = "/mail-server";
     };
  */

  /* inputs.vika = {
       type = "sourcehut";
       owner = "~vikanezrimaya";
       repo = "nix-flake";
     };
  */

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

  inputs.oxalica = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.pre-commit = {
    url = "github:cachix/pre-commit-hooks.nix";
    inputs.nixpkgs.follows = "/nixpkgs";
    inputs.nixpkgs-stable.follows = "/nixpkgs";
  };

  inputs.kloenk-cv = {
    url = "gitlab:kloenk/cv?host=cyberchaos.dev";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.rfl-nix-dev = {
    url = "gitlab:kloenk/rfl-nix-slides?host=cyberchaos.dev";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, lix, lix-module, moodlepkgs, mail-server
    , kloenk-www, dns, darwin, sops-nix, colmena, jlly, fleet_bot, p3tr
    , sysbadge, oxalica, disko, ... }:
    let
      lib = nixpkgs.lib.extend (import ./lib);

      overlayCombined = system: [
        #nix.overlays.default
        #(final: prev: { nix = nix.packages.${system}.nix; })
        #home-manager.overlay
        self.overlays.kloenk
        self.overlays.dns
        self.overlays.iso
        moodlepkgs.overlay
        kloenk-www.overlay
        colmena.overlay
        jlly.overlays.default
        fleet_bot.overlays.default
        p3tr.overlays.default
        sysbadge.overlays.sysbadge
        oxalica.overlays.default
        lix-module.overlays.default
        (_final: _prev: { inherit lib; })
      ];

      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forSomeSystems = systems: f:
        nixpkgs.lib.genAttrs systems (system: f system);
      forAllSystems = f: forSomeSystems systems f;
      #forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # Memoize nixpkgs for different platforms for efficiency.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.tests ] ++ (overlayCombined system);
        });

      darwinHosts = nixpkgs.lib.filterAttrs
        (name: host: if host ? darwin then host.darwin else false)
        (import ./darwin { });

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
      overlays.dns = final: prev:
        let
          dns = inputs.dns.lib.${final.stdenv.targetPlatform.system}.dns;
          lib = final.lib;
          common = import ./services/dns/common.nix { inherit dns lib; };
        in {
          de_kloenk = import ./services/dns/zones/de.kloenk.nix {
            inherit dns lib common;
          };
          eu_kloenk = import ./services/dns/zones/eu.kloenk.nix {
            inherit dns lib common;
          };

          dev_sysbadge = import ./services/dns/zones/dev.sysbadge.nix {
            inherit dns lib common;
          };
          de_p3tr1ch0rr = import ./services/dns/zones/de.p3tr1ch0rr.nix {
            inherit dns lib common;
          };
        };
      overlays.iso = final: prev: {
        iso = let
          c = (nixpkgs.lib.nixosSystem {
            system = final.stdenv.targetPlatform.system;
            modules = [
              (import ./profiles/iso.nix)
              {
                nixpkgs.overlays =
                  (overlayCombined final.stdenv.targetPlatform.system);
              }
              sops-nix.nixosModules.sops
              colmena.nixosModules.deploymentOptions
              inputs.home-manager.nixosModules.home-manager
              self.nixosModules.vouch-proxy
              self.nixosModules.kloenk

              self.nixosModules.helix
            ];
            specialArgs.inputs = inputs;
            specialArgs.self = self;
          });
        in c // c.config.system.build.isoImage;
      };
      overlays.tests = (import ./tests self);

      inherit lib;

      legacyPackages = forAllSystems (system: nixpkgsFor.${system});

      packages = (forAllSystems (system: { }))
        // (forSomeSystems [ "x86_64-linux" "aarch64-linux" ]
          (system: { inherit (nixpkgsFor.${system}) iso; }));

      apps = forAllSystems (system: {
        update-ssh-keys = {
          type = "app";
          program = toString nixpkgsFor.${system}.update-ssh-host-keys;
        };
        update-dns = {
          type = "app";
          program = let
            pkgs = nixpkgsFor.${system};
            script = pkgs.writeShellScriptBin "update-dns" ''
              ${pkgs.kloenk-octodns}/bin/octodns-sync --config-file ${pkgs.kloenk-octodns-config} $@
            '';
          in "${script}/bin/update-dns";
        };
      });

      nixosConfigurations =
        let hive = inputs.colmena.lib.makeHive self.outputs.colmena;
        in hive.nodes;

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = (overlayCombined "x86_64-linux");
          };
          nodeNixpkgs.varda = import nixpkgs {
            system = "aarch64-linux";
            overlays = (overlayCombined "aarch64-linux");
          };
          nodeNixpkgs.ktest = import nixpkgs {
            system = "aarch64-linux";
            overlays = (overlayCombined "aarch64-linux");
          };
          nodeNixpkgs.strider = import nixpkgs {
            system = "aarch64-linux";
            overlays = (overlayCombined "aarch64-linux");
          };
          nodeNixpkgs.vaire = import nixpkgs {
            system = "aarch64-linux";
            overlays = (overlayCombined "aarch64-linux");
          };
          nodeNixpkgs.gimli = import nixpkgs {
            system = "aarch64-linux";
            overlays = (overlayCombined "aarch64-linux");
          };
          nodeNixpkgs.sc-social = import nixpkgs {
            system = "aarch64-linux";
            overlays = (overlayCombined "aarch64-linux");
          };
          nodeNixpkgs.gloin = import nixpkgs {
            system = "x86_64-linux";
            overlays = (overlayCombined "x86_64-linux");
          };
          nodeNixpkgs.elros = import nixpkgs {
            system = "aarch64-linux";
            overlays = (overlayCombined "aarch64-linux");
          };
          nodeNixpkgs.fingolfin = import nixpkgs {
            system = "aarch64-linux";
            overlays = (overlayCombined "aarch64-linux");
          };

          #allowApplyAll = false;

          specialArgs.inputs = inputs;
          specialArgs.self = self;
          specialArgs.lib = lib;
        };

        defaults = { pkgs, ... }: {
          disabledModules = [
            "services/games/minecraft-server.nix"
            "services/web-apps/wordpress.nix"
            "services/web-apps/homebox.nix"
            "services/web-apps/moodle.nix"
          ];
          imports = [
            ./profiles/base/nixos
            #home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            self.nixosModules.matrix-sliding-sync
            jlly.nixosModules.default
            fleet_bot.nixosModules.default
            p3tr.nixosModules.default
            disko.nixosModules.default

            self.nixosModules.deluge2
            #self.nixosModules.firefox
            self.nixosModules.wordpress
            self.nixosModules.transient
            self.nixosModules.helix
            self.nixosModules.kloenk
            self.nixosModules.vouch-proxy
            self.nixosModules.backups
            self.nixosModules.evremap
            self.nixosModules.inventree
            self.nixosModules.kitchenowl
            self.nixosModules.homebox
            ./modules/moodle.nix

            #lix-module.nixosModules.default
            # TODO: 
            #vika.nixosModules.colorfulMotd
            #vika.nixosModules.secureSSHClient

            inputs.home-manager.nixosModules.default
          ];
          # disable home-manager manpage (breaks hydra see https://github.com/rycee/home-manager/issues/1262)
          #home-manager.users.kloenk.manual.manpages.enable = false;

          environment.systemPackages = [ # pkgs.colmena
          ];
          #home-manager.home.enableNixpkgsReleaseCheck = false;

          nix.channel.enable = false;
          documentation.nixos.enable = false;

          deployment = {
            buildOnTarget = true;
            allowLocalDeployment = true;
            targetPort = 62954;
            targetUser = "kloenk";
          };
        };

        # hetzner
        varda = { pkgs, node, ... }: {
          deployment = {
            targetHost = "varda.kloenk.de";
            tags = [ "hetzner" "falkenstein" "remote" ];
          };

          imports = [
            ./hosts/varda
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };
        vaire = { pkgs, node, ... }: {
          deployment = {
            targetHost = "vaire.kloenk.de";
            tags = [ "hetzner" "falkenstein" "remote" ];
          };

          imports = [
            ./hosts/vaire
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };
        gimli = { pkgs, nodes, ... }: {
          deployment = {
            targetHost = "gimli.kloenk.de";
            tags = [ "hetzner" "falkenstein" "remote" ];
          };

          imports = [
            ./hosts/gimli
            mail-server.nixosModules.mailserver
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };

        sc-social = { pkgs, nodes, ... }: {
          deployment = {
            targetHost = "starcitizen.social";
            tags = [ "hetzner" "falkenstein" "remote" "fleetyards" ];
          };

          imports = [
            ./hosts/sc-social
            self.nixosModules.restic-backups
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };

        # USee
        moodle-usee = { pkgs, nodes, ... }: {
          deployment.targetHost = "moodle-usee.kloenk.de";
          deployment.tags = [ "usee" "remote" ];

          imports = [
            ./hosts/moodle-usee
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };

        fingolfin = { pkgs, nodes, ... }: {
          deployment.targetHost = "fingolfin.kloenk.dev";
          deployment.tags = [ "usee" "remote" "hetzner" ];

          imports = [
            ./hosts/fingolfin
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };

        # Pony
        thrain = { pkgs, nodes, ... }: {
          deployment.targetHost = "thrain.net.kloenk.de";
          deployment.tags = [ "pony" "local" ];

          imports = [ ./hosts/thrain ];

          # ZFS kernel
          nixpkgs.config.allowBroken = true;
        };
        elros = { pkgs, nodes, ... }: {
          deployment.targetHost = "elros.net.kloenk.de";
          deployment.tags = [ "pony" "local" ];

          imports = [ ./hosts/elros ];
        };
        elrond = { pkgs, nodes, ... }: {
          deployment.targetHost = "elrond.net.kloenk.de";
          deployment.tags = [ "pony" "local" ];

          imports = [ ./hosts/elrond ];
          users.users.kloenk.packages =
            [ inputs.nixpkgs.legacyPackages.x86_64-linux.nil ];
        };

        gloin = { pkgs, nodes, ... }: {
          deployment.targetHost = "gloin.net.kloenk.de";
          deployment.tags = [ "local" ];

          imports = [ ./hosts/gloin ];
          users.users.kloenk.packages =
            [ inputs.nixpkgs.legacyPackages.x86_64-linux.nil ];
        };

        strider = { pkgs, nodes, ... }: {
          deployment.targetHost = "192.168.64.102";
          deployment.tags = [ "vm" "frodo" ];

          imports = [
            ./hosts/strider
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };

        ktest = { pkgs, nodes, ... }: {
          deployment.targetHost = "192.168.64.101";
          deployment.tags = [ "vm" "frodo" ];

          imports = [
            ./hosts/ktest
            (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
          ];
        };
      };

      nixosModules = {
        ferm2 = import ./modules/ferm2;
        deluge2 = import ./modules/deluge.nix;
        autoUpgrade = import ./modules/upgrade;
        #firefox = import ./modules/firefox;
        #secrets = import ./modules/secrets;
        transient = import ./modules/transient;
        kloenk = import ./modules/kloenk;

        restya-board = import ./modules/restya-board;
        restic-backups = import ./modules/restic-backups.nix;

        wordpress = import ./modules/wordpress.nix;
        matrix-sliding-sync = import ./modules/matrix-sliding-sync;
        helix = import ./modules/helix;
        vouch-proxy = import ./modules/vouch-proxy;
        backups = import ./modules/backups;
        evremap = import ./modules/evremap;
        inventree = import ./modules/inventree.nix;
        kitchenowl = import ./modules/kitchenowl;
        homebox = import ./modules/homebox;
      };

      darwinModules = {
        epmd = import ./modules/darwin/epmd;
        git = import ./modules/darwin/git.nix;
        helix = import ./modules/helix/darwin.nix;
        emacs = import ./modules/kloenk/emacs.nix;
      };

      darwinConfigurations = (nixpkgs.lib.mapAttrs (name: host:
        (darwin.lib.darwinSystem {
          system = host.system;
          modules = [
            { nixpkgs.overlays = (overlayCombined host.system); }
            ./profiles/base/darwin
            #home-manager.nixosModules.home-manager
            (import (./darwin + "/${name}/darwin.nix"))
            sops-nix.darwinModules.sops

            self.darwinModules.epmd
            self.darwinModules.git
            self.darwinModules.helix
            self.darwinModules.emacs

            inputs.home-manager.darwinModules.home-manager
            #inputs.mac-app-util.darwinModules.default
            ({ pkgs, config, inputs, ... }:
              {
                # home-manager.users.kloenk.imports =
                #   [ inputs.mac-app-util.homeManagerModules.default ];
              })
          ];
          specialArgs.inputs = inputs;
          specialArgs.self = self;
        })) darwinHosts);

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          kernel = pkgs.callPackage ./dev/kernel.nix { };
          kernel_nightly = self.devShells.${system}.kernel.override {
            rustAttrs = pkgs.rust-bin.nightly.latest;
          };
          zephyr = let
            nrfPkgs = import inputs.nixpkgs-nrf {
              inherit system;
              config = {
                allowUnfree = true;
                segger-jlink.acceptLicense = true;
              };
            };
          in pkgs.callPackage ./dev/zephyr.nix {
            python3 = pkgs.python310;
            inherit (nrfPkgs) nrf-command-line-tools;
          };
          smp-rs = pkgs.callPackage ./dev/smp-rs.nix { };
          default = pkgs.mkShell {
            nativeBuildInputs = [ pkgs.nixfmt pkgs.colmena pkgs.sops ];
            inherit (self.checks.${system}.pre-commit) shellHook;
          };
        });

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt);

      checks = forAllSystems (system: {
        pre-commit = inputs.pre-commit.lib.${system}.run {
          src = self;
          hooks = { nixfmt.enable = true; };
        };
      });
    };
  nixConfig = {
    extra-substituters = [ "https://kloenk.cachix.org" ];
    extra-trusted-public-keys =
      [ "kloenk.cachix.org-1:k52XSkCLOxnmEnjzuedYOzf0MtQp8P3epqOmAlCHYpc=" ];
  };
}
