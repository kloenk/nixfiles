{ ... }:

{
  networking.firewall.extraForwardRules = ''
    iifname "guest" meta mark 133745;
    iifname "wg0" accept;

    oifname "guest" accept;
    # iifname "guest" ip daddr 192.168.178.1 accept;
    iifname "guest" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.178.0/16 } drop;
    iifname "guest" accept;
  '';
  networking.nftables.tables = {
    nat = {
      name = "nat";
      family = "inet";
      # enable = false;
      content = ''
        chain postrouting {
          type nat hook postrouting priority srcnat;

          iifname "wg0" masquerade;
          iifname "guest" ip saddr 192.168.45.0/24 snat to 192.168.178.248;
        }
      '';
    };
  };
}
