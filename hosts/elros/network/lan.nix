{ pkgs, ... }:

{
  systemd.network = {
    netdevs."20-lan" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "lan";
      };
    };
    networks."20-lan" = {
      matchConfig = {
        Name = "lan";
        Type = "bridge";
      };
      networkConfig = {
        LinkLocalAddressing = "ipv6";
        IPv6AcceptRA = "no";
        IPv6SendRA = "yes";
        DHCPPrefixDelegation = "yes";
        DHCPServer = "no";
        DNS = [ "10.84.16.1" "fe80::1" ];
      };
      addresses =
        [ { Address = "10.84.16.1/22"; } { Address = "fe80::1/64"; } ];
      ipv6SendRAConfig = { };
      dhcpPrefixDelegationConfig = {
        UplinkInterface = "dtag-ppp";
        SubnetId = "0x01";
        Announce = "yes";
      };
    };
  };

  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "lan" ];
    subnet4 = [{
      id = 1;
      interface = "lan";
      pools = [{ pool = "10.84.16.20 - 10.84.17.220"; }];
      subnet = "10.84.16.0/20";

      option-data = [
        {
          name = "routers";
          data = "10.84.16.1";
        }
        {
          name = "domain-name-servers";
          data = "10.84.16.1";
        }
        {
          name = "domain-name";
          data = "isengard.home.kloenk.de";
        }
      ];

      reservations = [{
        hw-address = "e4:8d:8c:c7:49:00";
        next-server = "10.84.16.1";
        boot-file-name = "/public/initramfs.bin";
      }];

      ddns-qualifying-suffix = "isengard.home.kloenk.de";

    }];
  };

  services.atftpd = {
    enable = true;
    root = "${pkgs.linkFarm "tftp" [{
      name = "public";
      path = "/persist/data/public/tftp";
    }]}";
  };
}
