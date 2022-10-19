{
  description = "Kloenk's NixOS configuration";

  inputs.home-manager = {
    type = "github";
    owner = "nix-community";
    repo = "home-manager";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

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

  inputs.nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  inputs.nix-minecraft.inputs.nixpkgs.follows = "/nixpkgs";

  outputs = inputs@{ self, nixpkgs, nix, moodlepkgs, mail-server, kloenk-www
    , dns, darwin, sops-nix, vika, ... }:
    let
      overlayCombined = system: [
        #nix.overlays.default
        (final: prev: { nix = nix.packages.${system}.nix; })
        #home-manager.overlay
        self.overlay
        moodlepkgs.overlay
        kloenk-www.overlay
        inputs.nix-minecraft.overlay
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
      colmena = {
        meta = { nixpkgs = import nixpkgs { system = "x86_64-linux"; }; };

        defaults = { pkgs, ... }: {
          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            inputs.nix-minecraft.nixosModules.minecraft-servers
            vika.nixosModules.matrix-sliding-sync-proxy
          ];
          imports = [ ./configuration/common ];
          # disable home-manager manpage (breaks hydra see https://github.com/rycee/home-manager/issues/1262)
          home-manager.users.kloenk.manual.manpages.enable = false;

          deployment.buildOnTarget = true;
        };

        thrain = {
          deployment.allowLocalDeployment = true;
          deployment.targetHost = null;

          imports = [ ./configuration/hosts/thrain ];
        };
      };
    };
}
