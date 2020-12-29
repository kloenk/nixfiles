{ pkgs, config, lib, ... }:

{
  networking.firewall.allowedUDPPorts = [ 53 853 ];
  networking.firewall.allowedTCPPorts = [ 53 853 ];

  # running local coredns, disabling resolved
  services.resolved.enable = false;

  services.coredns = {
    enable = true;
    config = ''
      (log) {
        prometheus
        errors
      }

      . {
        cache
        chaos
        health
        import log
        forward . tls://1.1.1.1 tls://1.0.0.1
      }
      fritz.box {
        import log
        forward fritz.box 192.168.178.1
      }
      rc3.world {
        import log
        forward . 135.181.148.31 78.46.190.44
      }
    '';
  };
}
