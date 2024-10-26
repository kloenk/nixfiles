{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedUDPPorts = [
    51820 # wg0
    51830 # wg-thrain
  ];

  # NATING
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  networking.nftables.tables.nat = {
    family = "inet";
    content = ''
      chain postrouting {
        type nat hook postrouting priority srcnat;

        iifname "wg0" oifname { eth0, buw0 } masquerade;
      }
    '';
  };
  networking.firewall.extraForwardRules = ''
    iifname "wg0" accept;
  '';

  k.wg.id = 1;
  k.wg.net = true;
  k.wg.mobile = false;

  systemd.network.netdevs."30-wg0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
    };
    wireguardConfig = {
      FirewallMark = 51820;
      ListenPort = 51820;
      PrivateKeyFile = config.sops.secrets."wireguard/wg0".path;
    };
    wireguardPeers = [
      /* {
             AllowedIPs = [
               "192.168.42.102/32"
               #"195.39.246.10" # ???
             ];
             PublicKey = "";
             PersistentKeepalive = 21;
         }
      */

      { # gimli
        AllowedIPs = [
          "192.168.242.2/32"
          "2a01:4f8:c013:1a4b:ecba::2/128"
          "2a01:4f8:c013:1a4b:ecba:0:21:0/120"
        ];
        PublicKey = "vVIbHzXr99y1dm80LbSViIUmlym/yt3+Ra48IcZQ+AY=";
        Endpoint = "gimli.kloenk.de:51820";
      }
      { # vaire
        AllowedIPs = [ "192.168.242.3/32" "2a01:4f8:c013:1a4b:ecba::3/128" ];
        PublicKey = "vGv9DvJ+6hTwFV0Jq5vaw2i32LXl8k87S58zra276RA=";
        Endpoint = "vaire.kloenk.de:51820";
      }
      { # fingolfin
        AllowedIPs = [ "192.168.242.4/32" "2a01:4f8:c013:1a4b:ecba::4/128" ];
        PublicKey = "GdiRay3/MTYASK7n14JjaGxEROx6no/R6Zb8lTo91nM=";
        Endpoint = "fingolfin.kloenk.dev:51820";
      }

      { # thrain
        AllowedIPs = [
          "192.168.242.101/32"
          "192.168.178.0/24"
          "2a01:4f8:c013:1a4b:ecba::101/128"
        ];
        PublicKey = "RiRB/fiZ/x88f78kRQasSwWYBuBjc5DxW2OFaa67zjg=";
        PersistentKeepalive = 21;
      }
      { # elros
        AllowedIPs =
          [ "192.168.242.102/32" "2a01:4f8:c013:1a4b:ecba::102/128" ];
        PublicKey = "HI/xAEvFIvPwnTIv7H1WF8Z5d+FBjodLqaLBdfBlfAk=";
        PersistentKeepalive = 21;
      }

      { # frodo
        AllowedIPs =
          [ "192.168.242.201/32" "2a01:4f8:c013:1a4b:ecba::201/128" ];
        PublicKey = "SpO+SIv/XzgKCuWH3SN1qNknZ+X4HWf48SQNl6Gw+SM=";
        PersistentKeepalive = 21;
      }
      { # windoof
        AllowedIPs =
          [ "192.168.242.202/32" "2a01:4f8:c013:1a4b:ecba::202/128" ];
        PublicKey = "aSkX5/y831rSZib/l0QhC1mmmaggNjdMNfQ0Qrz8rxA=";
        PersistentKeepalive = 21;
      }
      { # elrond
        AllowedIPs =
          [ "192.168.242.204/32" "2a01:4f8:c013:1a4b:ecba::204/128" ];
        PublicKey = "6kwWS4u3lM+iGAf1lF79lm/mmE8kOlFtk7ipqNpKd3g=";
        PersistentKeepalive = 21;
      }
      { # gloin
        AllowedIPs =
          [ "192.168.242.205/32" "2a01:4f8:c013:1a4b:ecba::205/128" ];
        PublicKey = "4Bwytj56G/CueL/P454SSE6Sq7wafGd/cJlFri5LxTw=";
        PersistentKeepalive = 21;
      }
      { # sting
        AllowedIPs =
          [ "192.168.242.210/32" "2a01:4f8:c013:1a4b:ecba::210/128" ];
        PublicKey = "iSYB99dCUvYhHAz5HaPSzhXYPyyntOtiucrDUBFVvBE=";
        PersistentKeepalive = 21;
      }
    ];
  };
  systemd.network.networks."30-wg0" = {
    name = "wg0";
    linkConfig = { RequiredForOnline = "no"; };
    addresses = [
      { Address = "192.168.242.1/24"; }
      { Address = "2a01:4f8:c013:1a4b:ecba::1/80"; }
      { Address = "2a01:4f8:c013:1a4b:ecba:1337::1/80"; }
    ];
    routes = [
      { Destination = "192.168.242.0/24"; }
      { Destination = "192.168.178.0/24"; }
      {
        Destination = "2a01:4f8:c013:1a4b:ecba::/80";
        PreferredSource = "2a01:4f8:c013:1a4b:ecba::1";
      }
    ];
  };

  systemd.network.netdevs."30-wg-thrain" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg-thrain";
      Description = "unlock wireguard network for thrain in initramfs";
    };
    wireguardConfig = {
      ListenPort = 51830;
      PrivateKeyFile = config.sops.secrets."wireguard/wg-thrain".path;
    };
    wireguardPeers = [{
      AllowedIPs = [ "2a01:4f8:c013:1a4b:ecba:1338::101/128" ];
      PublicKey = "JVdV4kGKVEiiVVe1T07lXhpP2BnrVHYUPHWk19nN5jw=";
    }];
  };
  systemd.network.networks."30-wg-thrain" = {
    name = "wg-thrain";
    linkConfig.RequiredForOnline = "no";
    addresses = [{ Address = "2a01:4f8:c013:1a4b:ecba:1338::1/120"; }];
    routes = [{ Destination = "2a01:4f8:c013:1a4b:ecba:1338::1/120"; }];
  };

  networking.hosts = { };

  systemd.services.buw0 = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = let
      script = pkgs.writeShellScript "script" ''
        # Set up split tunneling
        export CISCO_SPLIT_INC=1
        export CISCO_SPLIT_INC_0_ADDR=132.195.0.0
        export CISCO_SPLIT_INC_0_MASK=255.255.0.0
        export CISCO_SPLIT_INC_0_MASKLEN=16
        export CISCO_SPLIT_INC_0_PROTOCOL=0
        export CISCO_SPLIT_INC_0_SPORT=0
        export CISCO_SPLIT_INC_0_DPORT=0

        export INTERNAL_IP4_DNS=
        . ${pkgs.vpnc-scripts}/bin/vpnc-script
      '';
    in ''
      cat $CREDENTIALS_DIRECTORY/buw0.config > buw0.config
      echo "script=${script}" >> buw0.config
      cat $CREDENTIALS_DIRECTORY/buw0.pass | ${pkgs.openconnect}/bin/openconnect https://vpn.uni-wuppertal.de --passwd-on-stdin --config buw0.config
    '';
    serviceConfig = {
      LoadCredential = [
        "buw0.pass:${config.sops.secrets."buw/vpn/pass".path}"
        "buw0.config:${config.sops.secrets."buw/vpn/config".path}"
      ];

      Restart = "always";
      RestartSec = "60s";
      WorkingDirectory = "/run/buw0";

      # sandboxing
      RuntimeDirectory = "buw0";
      ReadWritePaths = [ "/dev/net" ];
      NoNewPrivileges = true;
      PrivateTmp = true;
      #PrivateDevices = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      #RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
      RestrictRealtime = true;
      #RestrictNamespaces = true;
      MemoryDenyWriteExecute = true;
      DevicePolicy = "closed";
      DeviceAllow = [ "/dev/net/tun rwm" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_MKNOD" ];
    };
  };

  users.users.systemd-network.extraGroups = [ "keys" ];
  sops.secrets."wireguard/wg0".owner = "systemd-network";
  sops.secrets."wireguard/wg-thrain".owner = "systemd-network";
  sops.secrets."buw/vpn/pass".owner = "root";
  sops.secrets."buw/vpn/config".owner = "root";
}
