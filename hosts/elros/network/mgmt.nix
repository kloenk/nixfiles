{ ... }:

{
  systemd.network = {
    networks."10-eth2".vlan = [ "mgmt" ];
    netdevs."15-mgmt" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "mgmt";
        MACAddress = "27:D1:8F:E4:DA:92";
      };
      vlanConfig.Id = 51;
    };
    networks."15-mgmt" = {
      matchConfig = {
        Name = "mgmt";
        Type = "vlan";
      };
      networkConfig = {
        LinkLocalAddressing = "ipv6";
        IPv6AcceptRA = "no";
        IPv6SendRA = "yes";
        DHCPPrefixDelegation = "no";
        DHCPServer = "no";
      };
      addresses = [
        { Address = "10.51.0.1/24"; }
        { Address = "fd31:67d1:d37d:51::1/64"; }
        { Address = "fe80::1/64"; }
      ];
      ipv6Prefixes = [{
        Prefix = "fd31:67d1:d37d:51::/64";
        Assign = "yes";
      }];
    };
  };

  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "mgmt" ];
    subnet4 = [{
      id = 51;
      interface = "mgmt";
      pools = [{ pool = "10.51.0.100 - 10.51.0.199"; }];
      subnet = "10.51.0.0/24";
    }];
  };

  networking.firewall.extraForwardRules = ''
    iifname "mgmt" reject;
    oifname "mgmt" reject;
  '';
}
