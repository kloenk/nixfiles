{ ... }:

{
  imports = [
    ./ppp.nix

    ./dhcp
    ./dns
    ./iperf3.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall.extraForwardRules = ''
    iifname "wg0" accept;

    oifname "dtag-ppp" accept;
  '';
  networking.nftables.tables = {
    nat = {
      name = "nat";
      family = "inet";
      content = ''
        chain postrouting {
          type nat hook postrouting priority srcnat;

          iifname "wg0" masquerade;
          iifname "eth2" masquerade;
        }
      '';
    };
  };
}
