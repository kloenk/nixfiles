{ lib, pkgs, ... }: {
  services.resolved.enable = false;

  networking.firewall.interfaces = let
    allowDns = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  in { lan = allowDns; };

  services.kresd = {
    enable = true;
    instances = lib.mkDefault 8;
    package = pkgs.knot-resolver.override { extraFeatures = true; };
    listenPlain = [
      "[::1]:53"
      "127.0.0.1:53"
      "[fe80::1%lan]:53"

      "10.84.16.1:53"
    ];
    extraConfig = ''
      modules.load('view')
      modules.load('policy')

      localTrees = policy.todnames(
        {'isengard.home.kloenk.de.',
         '10.84.in-addr.arpa.'
        })
      policy.add(policy.suffix(policy.FLAGS({'NO_EDNS'}), localTrees))
      policy.add(policy.suffix(policy.STUB('127.0.0.11'), localTrees))

      -- whitelist queries identified by subnet
      view:addr('127.0.0.0/8', policy.all(policy.PASS))
      view:addr('::1/128', policy.all(policy.PASS))
      view:addr('fe80::/8', policy.all(policy.PASS))
      view:addr('192.168.242.0/24', policy.all(policy.PASS))
      view:addr('10.84.16.0/20', policy.all(policy.PASS))
      view:addr('10.84.20.0/24', policy.all(policy.PASS))
      view:addr('10.84.21.0/24', policy.all(policy.PASS))
      view:addr('10.84.22.0/24', policy.all(policy.PASS))

      -- disable drop, we are behind firewall
      -- -- drop everything that hasn't matched
      -- view:addr('0.0.0.0/0', policy.all(policy.DROP))
      -- view:addr('::/0', policy.all(policy.DROP))
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

  services.telegraf.extraConfig.inputs.prometheus =
    [{ urls = [ "http://localhost:8453/metrics" ]; }];
}
