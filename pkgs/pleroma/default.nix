{ lib, callPackage, beamPackages, fetchpatch, git, cmake, file }:

let
  mixnix = callPackage ./mixnix/mix2nix.nix {};

  pc_1_11_0 = beamPackages.buildHex {
    name = "pc";
    version = "1.11.0";
    sha256 = "0s00j4icaikwr1k0bv0dvbpp9nffqxvvppl51mmngkhrdhlbfq5c";
  };

in mixnix.mkPureMixPackage rec {
  name = "pleroma";
  inherit (callPackage ./source.nix {}) src version;

  beamDeps = [
    (beamPackages.buildMix {
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
    idna = rec {
      buildTool = "rebar3";
      version = "6.1.1";
      fetchHex = {
        sha256 = "13fzk603svf9dh81pggv021490p3gl53djwzkpmn433xkw70fqwa";
        url = "https://repo.hex.pm/tarballs/idna-${version}.tar";
      };
    };
    gun = deps.gun // {
      buildTool = "rebar3";
    };
    parse_trans = deps.parse_trans // {
      buildTool = "rebar3";
    };
    mimerl = rec {
      buildTool = "rebar3";
      version = "1.2.0";
      fetchHex = {
        sha256 = "1qqvk1gdyv0hcj7a1zz8xvrmjwdljhq3h32m7vymr388f7sx7qk7";
        url = "https://repo.hex.pm/tarballs/mimerl-${version}.tar";
      };
    };
    metrics = rec {
      buildTool = "rebar3";
      #version = "2.5.0";
      version = "1.0.1";
      fetchHex = {
        #sha256 = "0mqcg4pl8nc9m3yzl62vkcvniik4mz1vyjypf3qbb72jas6j3396";
        sha256 = "11l4d8s1q6cxlar96hwha3crj0llkvqfyfncrq9q5afdlbg99w15";
        url = "https://repo.hex.pm/tarballs/metrics-${version}.tar";
      };
    };
    unicode_util_compat = rec {
      buildTool = "rebar3";
      version = "0.7.0";
      fetchHex = {
        sha256 = "0y4s5wiwgv2r20mi7gdq80mxdim2vzj8kb235w4pg0dlk863i15w";
        url = "https://repo.hex.pm/tarballs/unicode_util_compat-${version}.tar";
      };
    };
    certifi = rec {
      deps = [ "parse_trans" ];
      buildTool = "rebar3";
      version = "2.5.3";
      fetchHex = {
        sha256 = "0l86nx4v8spk4liy28qwqj55vhsvcncpq3pf60x4z04c33kxggbh";
        url = "https://repo.hex.pm/tarballs/certifi-${version}.tar";
      };
    };
    prometheus_phx = deps.prometheus_phx // {
      deps = [
        "prometheus_ex"
      ];
    };
    hackney = deps.hackney // {
      buildTool = "rebar3";
      fetchGit = {
        inherit (deps.hackney.fetchGit) url rev;
        ref = "refs/heads/1.15.2-pleroma";
      };
    };
    eimp = deps.eimp // rec {
      version = "1.0.18";
      fetchHex = {
        sha256 = "185qsjxfk8xbva2zp9rsghrs3byaf0n2wn32zsyvwhbpr282ylxn";
        url = "https://repo.hex.pm/tarballs/eimp-${version}.tar";
      };
    };
    ssl_verify_fun = rec {
      buildTool = "mix";
      version = "1.1.6";
      fetchHex = {
        sha256 = "1c6lxgm5lbj8c9djzlp717yx8j0mjvywhpjgapbjqbf8j9b4yd6g";
        url = "https://repo.hex.pm/tarballs/ssl_verify_fun-${version}.tar";
      };
    };
  };

  mixConfig = {
    fast_html = { ... }: {
      nativeBuildInputs = [ cmake ];
    };
    syslog = { ... }: {
      patches = [ ./syslog.patch ];
      buildPlugins = [ pc_1_11_0 ];
    };
    crypt = {version, ...}: {
      postInstall = "mv $out/lib/erlang/lib/crypt-${version}/priv/{source,crypt}.so";
    };
    majic = { ... }: {
      buildInputs = [ file ];
    };
    eimp = { ... }: {
      patchPhase = ''
        echo '{plugins, [ { pc, { git, "git://github.com/blt/port_compiler.git", {tag, "v1.11.0"}}} ]}.' >> rebar.config
      '';
      buildPlugins = [ pc_1_11_0 ];
    };

    http_signatures = { ... }: {
      patchPhase = ''
        sed 's/:logger/&, :public_key/' -i mix.exs
      '';
    };
  };

  buildInputs = [ git ];
  preBuild = "echo 'import Mix.Config' > config/prod.secret.exs";
  postBuild = "mix release --path $out --no-deps-check";
}
