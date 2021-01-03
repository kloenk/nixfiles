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
  iluvatar = makeHost {
    host = "iluvatar.kloenk.dev";
    vm = true;
    mail = true;
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
  };

  thrain = makeHost {
    host = "192.168.178.248";
    # server = true;
  };


  sauron = makeHost {
    host = "sauron.kloenk.dev";
    vm = true;
    server = true;
  };

  nixos = makeHost {
    host = "192.168.178.0";
    prometheusExporters = [ ];
  };

  samwise = makeHost { host = "6.0.2.4"; };
  bilbo = makeHost { host = "10.211.55.3"; };

  usee-nschl = makeHost {
    host = "usee-nschl.kloenk.dev";
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
  moodle-usee = makeHost {
    host = "moodle-usee.kloenk.de";
    nixos = false;
    prometheusExporters = [ "node-exporter" ];
    server = true;
  };

  # for monitoring only
  # OSP streaming server
  knuddel-usee = makeHost {
    host = "knuddel-usee.kloenk.de";
    nixos = false;
    prometheusExporters = [ "node-exporter" ];
    server = true;
  };
}
