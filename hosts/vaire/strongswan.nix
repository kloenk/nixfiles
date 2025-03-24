{ ... }:

{
  k.strongswan = {
    enable = true;
    acme.enable = true;
    babel = {
      enable = true;
      public = true;
      id = {
        v4 = 3;
        v6 = "C8F1";
      };
    };
  };

  systemd.network.networks."40-lo" = {
    addresses = [
      { Address = "192.168.242.3/32"; }
      { Address = "2a01:4f8:c013:1a4b:ecba::3/128"; }
    ];
  };
  systemd.network.netdevs."30-wg0".enable = false;
}
