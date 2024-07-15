{ ... }:

{
  k.wg = {
    enable = true;
    id = 102;
    mobile = true; # TODO: Mobile for now as sleeping in a box
  };

  systemd.network = {
    links."10-eth1" = {
      matchConfig.Path = "platform-a41000000.pcie-pci-0004:41:00.0";
      linkConfig.Name = "eth1";
    };
    links."10-eth2" = {
      matchConfig.Path = "platform-a40800000.pcie-pci-0002:21:00.0";
      linkConfig.Name = "eth2";
    };

    networks."10-eth1" = {
      name = "eth1";
      DHCP = "yes";
    };
    networks."10-eth2" = {
      name = "eth2";
      vlan = [ "kloenk0" "lurch0" ];
    };

    netdevs."20-kloenk0" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "kloenk0";
      };
      vlanConfig.Id = 1001;
    };
    networks."20-kloenk0" = {
      name = "kloenk0";
      DHCP = "no";
      addresses = [{ Address = "10.84.23.1/24"; }];
    };

    netdevs."20-lurch0" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "lurch0";
      };
      vlanConfig.Id = 2001;
    };
    networks."20-lurch0" = {
      name = "lurch0";
      DHCP = "no";
      addresses = [{ Address = "10.84.24.1/24"; }];
    };
  };

  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  networking.nftables.tables.nat = {
    family = "inet";
    content = ''
      chain postrouting {
        type nat hook postrouting priority srcnat;

        iifname "kloenk0" oifname "eth1" masquerade;
        iifname "lurch0" oifname "eth1" masquerade;
      }
    '';
  };
  networking.firewall.extraForwardRules = ''
    iifname "kloenk0" mark set 1001 accept;
    iifname "lurch0" mark set 1002 accept;
  '';
}
