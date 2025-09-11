{ ... }:

{
  # let's not try to competing clients
  services.timesyncd.enable = false;

  services.ntpd-rs = {
    enable = true;
    useNetworkingTimeServers = false;
    settings = {
      source = [
        {
          mode = "pool";
          address = "ntp.time.nl";
          count = 3;
        }
        {
          mode = "pool";
          address = "0.nixos.pool.ntp.org";
          count = 2;
        }
      ];
      server = [{ listen = "[::]:123"; }];
    };
    metrics.enable = true;
  };
}
