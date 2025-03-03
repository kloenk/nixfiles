{ ... }:

{
  imports = [
    ./ppp.nix
    ./lan.nix
    ./iot.nix
    ./mgmt.nix

    ./dns
    ./kea.nix
    ./iperf3.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall.extraForwardRules = ''
    iifname "wg0" accept;

    oifname "dtag-ppp" accept;
    oifname "lan" meta nfproto ipv6 accept;
    iifname "lan" oifname "iot" accept;
  '';
  networking.nftables.tables = {
    nat = {
      name = "nat";
      family = "inet";
      content = ''
        chain postrouting {
          type nat hook postrouting priority srcnat;

          iifname "wg0" masquerade;
          #ct mark 0x50C95E9 oifname "lan" meta nfproto ipv4 masquerade;
          #ct mark 0x50C95E9 oifname "iot" meta nfproto ipv4 masquerade;
          iifname "lan" oifname "dtag-ppp" meta nfproto ipv4 masquerade;
          iifname "iot" oifname "dtag-ppp" meta nfproto ipv4 masquerade;
        }
      '';
    };
  };
}
