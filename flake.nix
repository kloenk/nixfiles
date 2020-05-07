{
  description = "Kloenk's Nixos configuration";

  inputs.home-manager = {
    type = "github";
    owner = "kloenk";
    repo = "home-manager";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.nixpkgs = {
    type = "github";
    owner = "nixos";
    repo = "nixpkgs";
    #    ref = "from-unstable";
  };

  inputs.nixpkgs-lopsided = {
    type = "github";
    owner = "lopsided98";
    repo = "nixpkgs";
    ref = "grub-initrd-secrets";
  };

  inputs.nixpkgs-es = {
    type = "github";
    owner = "kloenk";
    repo = "nixpkgs";
    ref = "feature/engelsystem";
  };

  inputs.mail-server = {
    type = "git";
    url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git";
    flake = false;
  };

  inputs.website = {
    type = "git";
    url = "https://git.pbb.lc/kloenk/website.git";
    flake = false;
  };

  inputs.secrets = {
    type = "git";
    url = "git+ssh://git@git.kloenk.de/kloenk/pass.git";
    flake = false;
  };

  inputs.nixpkgs-qutebrowser = {
    type = "github";
    owner = "kloenk";
    repo = "nixpkgs-qutebrowser";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, mail-server, website, secrets
    , nixpkgs-qutebrowser, nixpkgs-lopsided # grub patch
    , nixpkgs-es }:
    let

      systems = [ "x86_64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # Memoize nixpkgs for different platforms for efficiency.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay home-manager.overlay overlays ];
        });

      # patche modules
      patchModule = {
        disabledModules = [ "system/boot/loader/grub/grub.nix" ];
        imports = [
          "${nixpkgs-lopsided}/nixos/modules/system/boot/loader/grub/grub.nix"
          "${nixpkgs-es}/nixos/modules/services/web-apps/engelsystem.nix"
        ];
        nixpkgs.overlays = [ overlays ];
      };

      overlays = final: prev: {
        engelsystem = final.callPackage
          "${nixpkgs-es}/pkgs/servers/web-apps/engelsystem/default.nix" { };
        qutebrowser = nixpkgs-qutebrowser.packages."x86_64-linux".qutebrowser;
      };

      # iso image
      iso = system:
        (nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./lib/iso-image.nix)
            (import (nixpkgs
              + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"))
            nixpkgs.nixosModules.notDetected
            (import (nixpkgs + "/nixos/modules/installer/cd-dvd/channel.nix"))
            home-manager.nixosModules.home-manager
          ];
        }).config.system.build.isoImage;

      # evals
      hosts = import ./configuration/hosts { };
      nixosHosts = nixpkgs.lib.filterAttrs
        (name: host: if host ? nixos then host.nixos else false) hosts;
      makeSourcesModule = hostName:
        let
          inherit (nixpkgs) lib;
          inherit (lib) mkIf;
        in { lib, ... }: {
          options.sources = nixpkgs.lib.mkOption { };
          config.sources = inputs;
        };
    in {
      overlay = import ./pkgs/overlay.nix;

      legacyPackages = forAllSystems
        (system: nixpkgsFor.${system} // { isoImage = (iso system); });

      packages = forAllSystems (system: {
        inherit (self.legacyPackages.${system})
          isoImage home-manager redshift jblock deploy_secrets wallpapers;
      });

      nixosConfigurations = (nixpkgs.lib.mapAttrs (name: host:
        (nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux"; # TODO: change, for raspies and so
          modules = [
            { nixpkgs.overlays = [ self.overlay home-manager.overlay ]; }
            nixpkgs.nixosModules.notDetected
            home-manager.nixosModules.home-manager
            (import (./configuration + "/hosts/${name}/configuration.nix"))
            self.nixosModules.secrets
            self.nixosModules.ferm2
            self.nixosModules.deluge2
            (makeSourcesModule name)
            patchModule
          ] ++ (if (if (host ? vm) then host.vm else false) then
            (nixpkgs.lib.singleton
              (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")))
          else
            [ ]) ++ (if (if (host ? mail) then host.mail else false) then
              [ (import (mail-server + "/default.nix")) ] # nixos-mailserver
            else
              [ ]);
        })) nixosHosts);

      nixosModules = {
        secrets = import ./modules/secrets;
        ferm2 = import ./modules/ferm2;
        deluge2 = import ./modules/deluge.nix;
      };

      # apps
      apps = forAllSystems (system: {
        deploy_secrets = let
          app = self.packages.${system}.deploy_secrets.override {
            passDir = toString (secrets + "/");
          };
        in {
          type = "app";
          program = "${app}";
        };
      });
    };
}