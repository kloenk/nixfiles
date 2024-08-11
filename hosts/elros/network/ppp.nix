{ config, pkgs, utils, ... }:

{
  systemd.network = {
    networks."10-eth1" = {
      vlan = [ "dtag-wan" ];
      linkConfig.MTUBytes = toString 1600;
    };

    netdevs."20-dtag-wan" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "dtag-wan";
      };
      vlanConfig.Id = 7;
    };
    networks."20-dtag-wan" = {
      name = "dtag-wan";
      DHCP = "no";
      linkConfig.RequiredForOnline = "carrier";
    };

    networks."20-dtag-ppp" = {
      name = "dtag-ppp";
      DHCP = "ipv6";
    };
  };

  services.pppd = {
    enable = true;
    peers.dtag = {
      config = ''
        plugin pppoe.so dtag-wan
        user "''${PPPD_DTAG_USERNAME}"
        ifname dtag-ppp
        persist
        maxfail 0
        holdoff 5
        noipdefault
        lcp-echo-interval 20
        lcp-echo-failure 3
        mtu 1492
        hide-password
        defaultroute
        +ipv6
        debug
      '';
    };
  };

  environment.etc."ppp/peers/dtag".enable = false;

  systemd.services."pppd-dtag".serviceConfig = let
    preStart = utils.systemdUtils.lib.makeJobScript "pppd-dtag-pre-start" ''
      mkdir -p /etc/ppp/peers

      # Created files only readable by root
      umask u=rw,g=,o=

      # Copy config and substitute username
      rm -f /etc/ppp/peers/dtag
      ${pkgs.envsubst}/bin/envsubst -i "${
        config.environment.etc."ppp/peers/dtag".source
      }" > /etc/ppp/peers/dtag

      # Copy login secrets
      rm -f /etc/ppp/pap-secrets
      cat ${config.sops.secrets."pppd/secrets".path} > /etc/ppp/pap-secrets
      rm -f /etc/ppp/chap-secrets
      cat ${config.sops.secrets."pppd/secrets".path} > /etc/ppp/chap-secrets
    '';
  in {
    EnvironmentFile = [ config.sops.secrets."pppd/dtag/env".path ];
    ExecStartPre = [ "+${preStart}" ];
  };

  sops.secrets = {
    "pppd/dtag/env".owner = "root";
    "pppd/secrets".owner = "root";
  };
}
