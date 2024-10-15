{ config, pkgs, ... }:

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
      linkConfig = {
        RequiredForOnline = "degraded";
        RequiredFamilyForOnline = "ipv6";
      };
    };

    networks."20-dtag-ppp" = {
      matchConfig = {
        Name = "dtag-ppp";
        Type = "ppp";
      };
      networkConfig = {
        LinkLocalAddressing = "ipv6";
        DHCP = "ipv6";
      };
      dhcpV6Config = {
        PrefixDelegationHint = "::/56";
        WithoutRA = "solicit";
        UseHostname = "no";
        UseDNS = "no";
        UseNTP = "no";
      };
      dhcpPrefixDelegationConfig = {
        UplinkInterface = ":self";
        SubnetId = "0";
        Announce = "no";
      };
    };
  };

  networking.firewall.interfaces.dtag-ppp.allowedUDPPorts = [ 546 ];
  networking.firewall.extraForwardRules = ''
    iifname dtag-ppp tcp flags syn tcp option maxseg size set rt mtu
    oifname dtag-ppp tcp flags syn tcp option maxseg size set rt mtu
  '';

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
    preStart = pkgs.writeShellScript "pppd-dtag-pre-start" ''
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
