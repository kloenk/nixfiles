{
  description = "Kloenk's NixOS configuration";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      #    ref = "from-unstable";
    };

    nixpkgs-nrf = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-23.05";
    };

    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    lix-module = {
      url =
        "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };

    moodlepkgs = {
      type = "github";
      owner = "kloenk";
      repo = "moodlepkgs";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    mail-server = {
      type = "gitlab";
      owner = "simple-nixos-mailserver";
      repo = "nixos-mailserver";
      ref = "master";
    };

    kloenk-www = {
      type = "gitlab";
      owner = "kloenk";
      repo = "www";
      host = "cyberchaos.dev";
    };

    dns = {
      type = "github";
      owner = "kirelagin";
      repo = "dns.nix";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    darwin = {
      type = "github";
      owner = "lnl7";
      repo = "nix-darwin";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    sysbadge = {
      url = "gitlab:kloenk/sysbadge?host=cyberchaos.dev";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    oxalica = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    pre-commit = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "/nixpkgs";
      inputs.nixpkgs-stable.follows = "/nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    kloenk-cv = {
      url = "gitlab:kloenk/cv?host=cyberchaos.dev";
      inputs.nixpkgs.follows = "/nixpkgs";
    };

    rfl-nix-dev = {
      url = "gitlab:kloenk/rfl-nix-slides?host=cyberchaos.dev";
      inputs.nixpkgs.follows = "/nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, pre-commit, flake-utils, ... }:
    {
      overlays = {
        kloenk = final: prev: import (./pkgs/overlay.nix) inputs final prev;
        default = self.overlays.kloenk;

        iso = final: prev: {
          iso = let
            c = (nixpkgs.lib.nixosSystem {
              system = final.stdenv.targetPlatform.system;
              modules = [
                (import ./profiles/iso.nix)
                {
                  nixpkgs.overlays = [
                    self.overlays.default
                    inputs.colmena.overlay
                    inputs.lix-module.overlay
                  ];
                }
                inputs.sops-nix.nixosModules.sops
                inputs.colmena.nixosModules.deploymentOptions
                inputs.home-manager.nixosModules.home-manager
                self.nixosModules.vouch-proxy
                self.nixosModules.kloenk
              ];
              specialArgs.inputs = inputs;
              specialArgs.self = self;
            });
          in c // c.config.system.build.isoImage;
        };
      };

      lib = import ./lib;

      colmena = (import ./colmena.nix) inputs;
      colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena;
      nixosConfigurations = self.colmenaHive.nodes;

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
        helix = import ./modules/helix;
        vouch-proxy = import ./modules/vouch-proxy;
        backups = import ./modules/backups;
        evremap = import ./modules/evremap;
        inventree = import ./modules/inventree.nix;
        kitchenowl = import ./modules/kitchenowl;
        homebox = import ./modules/homebox;
      };

      # darwin
      darwinModules = {
        epmd = import ./modules/darwin/epmd;
        git = import ./modules/darwin/git.nix;
        helix = import ./modules/helix/darwin.nix;
        emacs = import ./modules/kloenk/emacs.nix;
      };

      darwinConfigurations = let
        darwinHosts = nixpkgs.lib.filterAttrs
          (name: host: if host ? darwin then host.darwin else false)
          (import ./darwin { });

      in (nixpkgs.lib.mapAttrs (name: host:
        (inputs.darwin.lib.darwinSystem {
          system = host.system;
          modules = [
            {
              nixpkgs.overlays = [ self.overlays.default ]
                ++ (with inputs; [ colmena.overlays.default ]);
            }
            ./profiles/base/darwin
            #home-manager.nixosModules.home-manager
            (import (./darwin + "/${name}/darwin.nix"))
            inputs.sops-nix.darwinModules.sops

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
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default self.overlays.iso ]
            ++ (with inputs; [
              moodlepkgs.overlay
              kloenk-www.overlays.default
              colmena.overlays.default
              sysbadge.overlays.sysbadge
              oxalica.overlays.default
              lix-module.overlays.default
            ]) ++ [
              (final: _prev: {
                nix-eval-jobs = final.writeShellScriptBin "nix-eval-jobs"
                  "echo nix-eval-jobs is broken; exit 1";
              })
            ];
        };
      in {
        legacyPackages = pkgs;

        pkgs = { inherit (pkgs) iso; };

        devShells = {
          kernel = pkgs.callPackage ./dev/kernel.nix { };
          kernel_nightly = self.devShells.${system}.kernel.override {
            rustAttrs = pkgs.rust-bin.nightly.latest;
          };
          nixfiles = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              self.formatter.${system}
              colmena
              sops
            ];
            inherit (self.checks.${system}.pre-commit) shellHook;
          };
          default = self.devShells.${system}.nixfiles;
        };

        formatter = pkgs.nixfmt;

        checks = {
          pre-commit = pre-commit.lib.${system}.run {
            src = ./.;
            hooks = { nixfmt.enable = true; };
          };
        };
      });

  nixConfig = {
    extra-substituters = [ "https://kloenk.cachix.org" ];
    extra-trusted-public-keys =
      [ "kloenk.cachix.org-1:k52XSkCLOxnmEnjzuedYOzf0MtQp8P3epqOmAlCHYpc=" ];
  };
}
