{ ... }:

{
  systemd.network = {
    networks."10-eth2" = { vlan = [ "win-ad" ]; };
    netdevs."20-win-ad" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "win-ad";
      };
      vlanConfig.Id = 1001;
    };
    networks."20-win-ad" = {
      matchConfig = {
        Name = "win-ad";
        Type = "vlan";
      };
      networkConfig = {
        LinkLocalAddressing = "ipv6";
        IPv6AcceptRA = "no";
        IPv6SendRA = "yes";
        DHCPPrefixDelegation = "yes";
        DHCPServer = "no";
        DNS = [ "10.84.21.1" "fe80::1" ];
      };
      addresses =
        [ { Address = "10.84.21.1/24"; } { Address = "fe80::1/64"; } ];
      ipv6SendRAConfig = { };
      dhcpPrefixDelegationConfig = {
        UplinkInterface = "dtag-ppp";
        SubnetId = "0x03";
        Announce = "yes";
      };
    };
  };

  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "win-ad" ];
    subnet4 = [{
      id = 3;
      interface = "win-ad";
      pools = [{ pool = "10.84.21.20 - 10.84.21.50"; }];
      subnet = "10.84.21.20/24";

      option-data = [
        {
          name = "routers";
          data = "10.84.21.1";
        }
        {
          name = "domain-name-servers";
          data = "10.84.21.1";
        }
        {
          name = "domain-name";
          data = "win.isengard.home.kloenk.de";
        }
      ];

      ddns-qualifying-suffix = "win.isengard.home.kloenk.de";
    }];
  };

  services.kresd.listenPlain = [ "10.84.21.1:53" "[fe80::1%win-ad]:53" ];
  networking.firewall = {
    extraForwardRules = ''
      iifname "win-ad" ip daddr 192.168.0.27 oifname "gre-*" accept;
      iifname "win-ad" ip6 daddr 2a02:8388:8c0:c600::1:27 oifname "gre-*" accept;
      iifname "win-ad" ip6 daddr 2a02:8388:8c0:c600:68e0:e8fe:ff51:8ca5 oifname "gre-*" accept;
    '';
    interfaces.win-ad = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 69 ];
    };
  };
}
