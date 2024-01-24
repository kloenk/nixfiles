{ lib, config, pkgs, ... }: {
  services.resolved.enable = false;

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 53 ];
  networking.firewall.interfaces.wg0.allowedUDPPorts = [ 53 ];

  services.kresd = {
    enable = true;
    package = pkgs.knot-resolver.override { extraFeatures = true; };
    extraConfig = ''
      modules.load('view')

      -- whitelist queries identified by subnet
      view:addr('127.0.0.0/8', policy.all(policy.PASS))
      view:addr('::1/128', policy.all(policy.PASS))
      view:addr('192.168.242.0/24', policy.all(policy.PASS))
      view:addr('192.168.178.0/24', policy.all(policy.PASS))
      view:addr('2a01:4f8:c013:1a4b:ecba::/80', policy.all(policy.PASS))

      -- drop everything that hasn't matched
      view:addr('0.0.0.0/0', policy.all(policy.DROP))
      view:addr('::/0', policy.all(policy.DROP))
      cache.size = 150*MB

      modules.load('http')

      net.listen('127.0.0.1', 8453, { kind = 'webmgmt' })
      http.prometheus.namespace = 'kresd_'

      modules = {
        predict = {
          window = 15,
          period = 24*(60/15)
        }
      }
    '';
  };

  services.telegraf.extraConfig.inputs.prometheus.urls =
    [ "http://localhost:8453/metrics" ];
}
