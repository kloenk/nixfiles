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

  durin-host = "192.168.178.249";
in {
  #peregrin = makeHost {
  #  host = "10.211.55.7";
  #  system = "aarch64-linux";
  #};

  # monitoring only - macOS

  iluvatar = makeHost {
    host = "iluvatar.kloenk.dev";
    vm = true;
    #mail = true;
    #wireguard.publicKey = "";
    #wireguard.endpoint = "";
    magicNumber = 252;
    server = true;
  };

  thrain = makeHost {
    host = "192.168.178.248";
    # server = true;
  };

  elrond = makeHost { host = "192.168.178.247"; };

  #durin = makeHost { host = durin-host; };

  #durin-rbuild = makeHost {
  #  host = durin-host;
  #  port = 62957;
  #  nixos = false;
  #};

  # Made some magic smoke
  #r-build = makeHost {
  #  host = "192.168.178.249";
  #  prometheusExporters = [ ];
  #  server = false;
  #};

  #samwisethink = makeHost {
  #  host = "192.168.178.1";
  #  server = false;
  #  prometheusExporters = [ ];
  #};

  #samwise = {
  #  host = "";
  #  server = false;
  #  system = "aarch64-linux";
  #  vm = true;
  #};

  # usee
  moodle-usee = makeHost {
    host = "moodle-usee.kloenk.dev";
    #nixos = false;
    prometheusExporters = [ "node-exporter" ];
    vm = true;
    server = true;
  };

  # for monitoring only
  # usee
  event = makeHost {
    host = "event.unterbachersee.de";
    nixos = false;
    vm = false;
    server = true;
    prometheusExporters = [ "node-exporter" "nginx-exporter" ];
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
