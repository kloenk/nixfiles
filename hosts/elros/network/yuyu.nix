{ ... }:

{
  systemd.network = {
    networks."10-eth2" = { vlan = [ "yuyu" ]; };
    netdevs."20-yuyu" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "yuyu";
      };
      vlanConfig.Id = 1002;
    };
    networks."20-yuyu" = {
      matchConfig = {
        Name = "yuyu";
        Type = "vlan";
      };
      networkConfig = {
        LinkLocalAddressing = "ipv6";
        IPv6AcceptRA = "no";
        IPv6SendRA = "yes";
        DHCPPrefixDelegation = "yes";
        DHCPServer = "no";
        DNS = [ "10.84.22.1" "fe80::1" ];
      };
      addresses =
        [ { Address = "10.84.22.1/24"; } { Address = "fe80::1/64"; } ];
      ipv6SendRAConfig = { };
      dhcpPrefixDelegationConfig = {
        UplinkInterface = "dtag-ppp";
        SubnetId = "0x04";
        Announce = "yes";
      };
    };
  };

  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "yuyu" ];
    subnet4 = [{
      id = 4;
      interface = "yuyu";
      pools = [{ pool = "10.84.22.20 - 10.84.22.50"; }];
      subnet = "10.84.22.20/24";

      option-data = [
        {
          name = "routers";
          data = "10.84.22.1";
        }
        {
          name = "domain-name-servers";
          data = "10.84.22.1";
        }
        {
          name = "domain-name";
          data = "yuyu.isengard.home.kloenk.de";
        }
      ];
    }];
  };

  services.kresd.listenPlain = [ "10.84.22.1:53" "[fe80::1%yuyu]:53" ];
  networking.firewall = {
    extraForwardRules = ''
      oifname "yuyu" meta nfproto ipv6 accept;
    '';
    interfaces.yuyu = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 69 ];
    };
  };
}
