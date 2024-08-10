{ config, ... }:

{
  networking.firewall.interfaces.eth2 =
    let inherit (config.services.iperf3) port;
    in {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ port ];
    };
  services.iperf3 = { enable = true; };
}
