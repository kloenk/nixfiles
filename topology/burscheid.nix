{ config, ... }:
let inherit (config.lib.topology) mkInternet mkRouter mkConnection mkSwitch;
in {
  nodes.internet = mkInternet { connections = mkConnection "router" "wan1"; };

  nodes.router = mkRouter "FritzBox" {
    info = "FRITZ!Box 7590";
    interfaceGroups =
      [ (builtins.genList (i: "eth${toString (i + 1)}") 4) [ "wan1" ] ];
    interfaces.eth1 = {
      addresses = [ "192.168.178.1" ];
      network = "net-burscheid";
    };
  };

  networks.net-burscheid = {
    name = "Burscheid Home Network";
    cidrv4 = "192.168.178.0/24";
  };

  nodes.kloenk-edgeswitch = mkSwitch "kloenk Edgeswitch" {
    info = "Unifi Edgeswitch 48 Lite";
    interfaceGroups = [
      [
        "0/10"
        "0/36"
        "0/38"
      ]
      #(builtins.genList (i: "0/${toString i}") 48)
      (builtins.genList (i: "0/${toString (48 + i)}") 4)
    ];
    connections."0/36" = mkConnection "elrond" "eth0";
    connections."0/38" = mkConnection "thrain" "eth0";
  };

  nodes.studio-switch = mkSwitch "studio-switch" {
    info = "HPE 1800-24G";
    interfaceGroups = [ (builtins.genList toString 24) ];
    connections."23" = mkConnection "kloenk-edgeswitch" "0/10";
    connections."20" = mkConnection "router" "eth1";
  };
}
