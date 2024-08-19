{ ... }:

{
  systemd.network = {
    networks."10-eth2" = { vlan = [ "iot" ]; };
    netdevs."25-iot" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "iot";
      };
      vlanConfig.Id = 501;
    };
    networks."25-iot" = {
      matchConfig = {
        Name = "iot";
        Type = "vlan";
      };
      networkConfig = {
        LinkLocalAddressing = "ipv6";
        IPv6AcceptRA = "no";
        IPv6SendRA = "yes";
        DHCPPrefixDelegation = "yes";
        DHCPServer = "no";
        DNS = [ "10.84.20.1" "fe80::1" ];
      };
      addresses =
        [ { Address = "10.84.20.1/24"; } { Address = "fe80::1/64"; } ];
      ipv6SendRAConfig = { };
      dhcpPrefixDelegationConfig = {
        UplinkInterface = "dtag-ppp";
        SubnetId = "0x02";
        Announce = "yes";
      };
    };
  };

  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "iot" ];
    subnet4 = [{
      id = 2;
      interface = "iot";
      pools = [{ pool = "10.84.20.20 - 10.84.20.220"; }];
      subnet = "10.84.20.20/24";

      option-data = [
        {
          name = "routers";
          data = "10.84.20.1";
        }
        {
          name = "domain-name-servers";
          data = "10.84.20.1";
        }
        {
          name = "domain-name";
          data = "iot.isengard.home.kloenk.de";
        }
      ];

      ddns-qualifying-suffix = "iot.isengard.home.kloenk.de";
    }];
  };

  services.kresd.listenPlain = [ "10.84.20.1:53" "[fe80::1%iot]:53" ];
  networking.firewall.interfaces.iot = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 69 53 ];
  };
}
