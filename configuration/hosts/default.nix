{ nixos-mailserver ? null }:

let
  pbbAS = { as = 207921; };

  makeHost = { host, port ? 62954, user ? "kloenk", prometheusExporters ? [
    "node-exporter"
    "nginx-exporter"
    #"nixos-exporter"
  ], hostname ? "${user}@${host}:${toString port}", server ? false, ...
    }@extraArgs:
    ({
      nixos = true;
      system = "x86_64-linux";
    } // extraArgs // {
      host.ip = host;
      host.port = port;
      host.user = user;
      inherit hostname prometheusExporters server;
    });

in {
  peregrin = makeHost {
    host = "10.211.55.5";
    system = "aarch64-linux";
  };

  # monitoring only - macOS
  # TODO: nix-on-darwin
  # bilbo = makeHost { host = "" };

  iluvatar = makeHost {
    host = "iluvatar.kloenk.dev";
    vm = true;
    #mail = true;
    #wireguard.publicKey = "";
    #wireguard.endpoint = "";
    magicNumber = 252;
    server = true;
  };

  manwe = makeHost {
    host = "manwe.kloenk.dev";
    vm = true;
    #mail = true;
    server = true;
  };

  gimli = makeHost {
    host = "gimli.kloenk.dev";
    vm = true;
    server = true;
    mail = true;
    prometheusExporters = [ "node-exporter" "nginx-exporter" "jitsi-exporter" ];
  };

  thrain = makeHost {
    host = "192.168.178.248";
    # server = true;
  };

  r-build = makeHost {
    host = "192.168.178.249";
    prometheusExporters = [ ];
    server = false;
  };

  samwise = makeHost {
    host = "192.168.178.1";
    server = false;
    prometheusExporters = [ ];
  };

  usee-nschl = makeHost {
    host = "usee-nschl.kloenk.dev";
    vm = true;
    server = true;
  };

  # usee
  event = makeHost {
    host = "event.kloenk.dev";
    vm = false;
    server = true;
    prometheusExporters = [ "node-exporter" "nginx-exporter" "jitsi-exporter" ];
  };

  # usee
  moodle-usee = makeHost {
    host = "moodle-usee.kloenk.dev";
    #nixos = false;
    prometheusExporters = [ "node-exporter" ];
    vm = true;
    server = true;
  };

  # for monitoring only
  bbb-wass = makeHost {
    host = "bbb-wass.kloenk.de";
    nixos = false;
    user = "root";
    prometheusExporters = [ "node-exporter" "bbb-exporter" ];
    #server = true;
  };

  # for monitoring only
  pve-usee = makeHost {
    host = "pve-usee.kloenk.de";
    nixos = false;
    user = "root";
    prometheusExporters = [
      "node-exporter"
      "pve-exporter"
    ]; # https://github.com/znerol/prometheus-pve-exporter
    server = true;
  };

  # for monitoring only
  bbb-usee = makeHost {
    host = "bbb-usee.kloenk.de";
    nixos = false;
    user = "root";
    prometheusExporters = [ "node-exporter" "bbb-exporter" ];
    server = true;
  };


  # for monitoring only
  # OSP streaming server
  knuddel-usee = makeHost {
    host = "knuddel-usee.kloenk.de";
    nixos = false;
    prometheusExporters = [ "node-exporter" "bbb-exporter" ];
    server = true;
  };
}
