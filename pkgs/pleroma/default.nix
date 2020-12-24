{ lib, callPackage, beamPackages, fetchpatch, git, cmake, elixir_1_10, file }:

let
  mixnix = callPackage ./mixnix/mix2nix.nix {};

in mixnix.mkPureMixPackage rec {
  name = "pleroma";
  inherit (callPackage ./source.nix {}) src version;

  elixir = elixir_1_10;

  beamDeps = [
    ((beamPackages.buildMix.override {
      elixir = elixir_1_10;
    }) {
      name = "restarter";
      version = "0.1.0";
      src = src + "/restarter";
    })
  ];

  importedMixNix = let
    deps = lib.filterAttrs (k: v: k != "nodex") (import ./mix.nix);
  in deps // {
    websocket_client = deps.websocket_client // {
      buildTool = "rebar3";
    };
    crypt = deps.crypt // {
      buildTool = "rebar3";
    };
    gun = deps.gun // {
      buildTool = "rebar3";
    };
    prometheus_phx = deps.prometheus_phx // {
      deps = [
        "prometheus_ex"
      ];
      fetchGit = {
        inherit (deps.prometheus_phx.fetchGit) url rev;
        ref = "refs/heads/no-logging";
      };
    };
    prometheus_ex = deps.prometheus_ex // {
      fetchGit = {
        inherit (deps.prometheus_ex.fetchGit) url rev;
        ref = "refs/heads/chore/elixir-1.11";
      };
    };
    majic = deps.majic // {
      fetchGit = {
        inherit (deps.majic.fetchGit) url rev;
        ref = "refs/heads/develop";
      };
    };
  };

  mixConfig = {
    fast_html = { ... }: {
      nativeBuildInputs = [ cmake ];
    };
    syslog = { ... }: {
      patches = [ ./syslog.patch ];
      buildPlugins = [ beamPackages.pc ];
    };
    crypt = {version, ...}: {
      postInstall = "mv $out/lib/erlang/lib/crypt-${version}/priv/{source,crypt}.so";
    };
    majic = { ... }: {
      buildInputs = [ file ];
    };
    eimp = { ... }: {
      patchPhase = ''
        echo '{plugins, [ { pc, { git, "git://github.com/blt/port_compiler.git", {tag, "v1.6.0"}}} ]}.' >> rebar.config
      '';
      buildPlugins = [
        beamPackages.pc
      ];
    };
  };

  buildInputs = [ git ];
  preBuild = "echo 'import Mix.Config' > config/prod.secret.exs";
  postBuild = "mix release --path $out --no-deps-check";
}
