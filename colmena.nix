{ nixpkgs, self, ... }@inputs:
let
  hostOverlays = [
    self.overlays.kloenk
    (_final: prev: { lib = prev.lib.extend (import ./lib); })
  ] ++ (with inputs; [
    moodlepkgs.overlay
    colmena.overlay
    sysbadge.overlays.default
    oxalica.overlays.default
    lix-module.overlays.default
    kloenk-www.overlays.default

  ]);

  lib = nixpkgs.lib.extend (import ./lib);

  aarchNixpkgs = import nixpkgs {
    system = "aarch64-linux";
    overlays = hostOverlays;
  };
  x86Nixpkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = hostOverlays;
  };
in {
  meta = {
    nixpkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = hostOverlays;
    };
    nodeNixpkgs.varda = import nixpkgs {
      system = "aarch64-linux";
      overlays = hostOverlays;
    };
    nodeNixpkgs.ktest = import nixpkgs {
      system = "aarch64-linux";
      overlays = hostOverlays;
    };
    nodeNixpkgs.strider = import nixpkgs {
      system = "aarch64-linux";
      overlays = hostOverlays;
    };
    nodeNixpkgs.vaire = import nixpkgs {
      system = "aarch64-linux";
      overlays = hostOverlays;
    };
    nodeNixpkgs.gimli = import nixpkgs {
      system = "aarch64-linux";
      overlays = hostOverlays;
    };
    nodeNixpkgs.sc-social = import nixpkgs {
      system = "aarch64-linux";
      overlays = hostOverlays;
    };
    nodeNixpkgs.gloin = import nixpkgs {
      system = "x86_64-linux";
      overlays = hostOverlays;
    };
    nodeNixpkgs.elros = aarchNixpkgs;
    nodeNixpkgs.fingolfin = import nixpkgs {
      system = "aarch64-linux";
      overlays = hostOverlays;
    };
    # vm on frodo
    nodeNixpkgs.maura = aarchNixpkgs;
    nodeNixpkgs.amdir = x86Nixpkgs;

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
    imports = [ ./profiles/base/nixos ./modules/moodle.nix ] ++ (with inputs; [
      home-manager.nixosModules.default
      sops-nix.nixosModules.sops
      disko.nixosModules.default
      niri-flake.nixosModules.niri
    ]) ++ (with self.nixosModules; [
      deluge2
      #firefox
      wordpress
      transient
      helix
      kloenk
      vouch-proxy
      backups
      evremap
      inventree
      kitchenowl
      homebox
    ]);
    # disable home-manager manpage (breaks hydra see https://github.com/rycee/home-manager/issues/1262)
    #home-manager.users.kloenk.manual.manpages.enable = false;

    environment.systemPackages = [ # pkgs.colmena
    ];
    #home-manager.home.enableNixpkgsReleaseCheck = false;

    nix.channel.enable = false;
    documentation.nixos.enable = false;

    niri-flake.cache.enable = false;

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
      inputs.mail-server.nixosModules.mailserver
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

  /* ??
     strider = { pkgs, nodes, ... }: {
       deployment.targetHost = "192.168.64.102";
       deployment.tags = [ "vm" "frodo" ];

       imports = [
         ./hosts/strider
         (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
       ];
     };
  */

  # router vm on frodo
  maura = { pkgs, nodes, ... }: {
    deployment.targetHost = "maura.net.kloenk.dev";
    deployment.tags = [ "vm" "frodo" ];

    imports = [
      ./hosts/maura
      (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
    ];
  };

  amdir = { pkgs, nodes, ... }: {
    deployment.targetHost = "amdir.net.kloenk.dev";
    deployment.tags = [ "vm" "vienna" ];

    imports = [
      ./hosts/amdir
      (import (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix"))
    ];
  };
}
