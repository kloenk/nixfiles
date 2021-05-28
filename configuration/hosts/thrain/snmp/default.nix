{ config, lib, pkgs, ... }:

{
    networking.firewall.interfaces.wg0.allowedTCPPorts = [ 9116 ];

    services.prometheus.exporters.snmp = {
        enable = true;
        configurationPath = ./snmp.yml;
    };
}