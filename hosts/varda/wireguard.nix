{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedUDPPorts = [
    51820 # wg0
  ];

  # NATING
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  #chain POSTROUTING {
  #  outerface enp1s0 SNAT to 195.39.247.6
  #}
  nftables.extraConfig = ''
    table ip nat {
      chain postrouting {
        type nat hook postrouting priority srcnat;
        ip saddr { 192.168.242.0-192.168.242.255 } oifname { "wg0" } snat to 192.168.242.1
        oifname "eth0" masquerade
        iifname "wg0" oifname "buw0" masquerade
      }
    }
  '';
  nftables.forwardPolicy = "accept";

  k.wg.id = 1;
  k.wg.net = true;

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
           wireguardPeerConfig = {
             AllowedIPs = [
               "192.168.42.102/32"
               #"195.39.246.10" # ???
             ];
             PublicKey = "";
             PersistentKeepalive = 21;
           };
         }
      */

      { # gimli
        wireguardPeerConfig = {
          AllowedIPs = [
            "192.168.242.2/32"
            "2a01:4f8:c013:1a4b:ecba::2/128"
            "2a01:4f8:c013:1a4b:ecba:0:21:0/120"
          ];
          PublicKey = "vVIbHzXr99y1dm80LbSViIUmlym/yt3+Ra48IcZQ+AY=";
          Endpoint = "gimli.kloenk.de:51820";
        };
      }

      { # thrain
        wireguardPeerConfig = {
          AllowedIPs = [
            "192.168.242.101/32"
            "192.168.178.0/24"
            "2a01:4f8:c013:1a4b:ecba::101/128"
          ];
          PublicKey = "RiRB/fiZ/x88f78kRQasSwWYBuBjc5DxW2OFaa67zjg=";
          PersistentKeepalive = 21;
        };
      }

      { # frodo
        wireguardPeerConfig = {
          AllowedIPs =
            [ "192.168.242.201/32" "2a01:4f8:c013:1a4b:ecba::201/128" ];
          PublicKey = "SpO+SIv/XzgKCuWH3SN1qNknZ+X4HWf48SQNl6Gw+SM=";
          PersistentKeepalive = 21;
        };
      }
      { # windoof
        wireguardPeerConfig = {
          AllowedIPs =
            [ "192.168.242.202/32" "2a01:4f8:c013:1a4b:ecba::202/128" ];
          PublicKey = "aSkX5/y831rSZib/l0QhC1mmmaggNjdMNfQ0Qrz8rxA=";
          PersistentKeepalive = 21;
        };
      }
      { # p3tr1ch0rr
        wireguardPeerConfig = {
          AllowedIPs =
            [ "192.168.242.203/32" "2a01:4f8:c013:1a4b:ecba::203/128" ];
          PublicKey = "HkPEHcCRrj7hMKaqCD8XSXNwFKtij8vuShgv1vb8CTg=";
          PersistentKeepalive = 21;
        };
      }
      { # elrond
        wireguardPeerConfig = {
          AllowedIPs =
            [ "192.168.242.204/32" "2a01:4f8:c013:1a4b:ecba::204/128" ];
          PublicKey = "6kwWS4u3lM+iGAf1lF79lm/mmE8kOlFtk7ipqNpKd3g=";
          PersistentKeepalive = 21;
        };
      }
      { # gloin
        wireguardPeerConfig = {
          AllowedIPs =
            [ "192.168.242.205/32" "2a01:4f8:c013:1a4b:ecba::205/128" ];
          PublicKey = "4Bwytj56G/CueL/P454SSE6Sq7wafGd/cJlFri5LxTw=";
          PersistentKeepalive = 21;
        };
      }
      { # sting
        wireguardPeerConfig = {
          AllowedIPs =
            [ "192.168.242.210/32" "2a01:4f8:c013:1a4b:ecba::210/128" ];
          PublicKey = "iSYB99dCUvYhHAz5HaPSzhXYPyyntOtiucrDUBFVvBE=";
          PersistentKeepalive = 21;
        };
      }

    ];
  };
  systemd.network.networks."30-wg0" = {
    name = "wg0";
    linkConfig = { RequiredForOnline = "no"; };
    addresses = [
      { addressConfig.Address = "192.168.242.1/24"; }
      { addressConfig.Address = "2a01:4f8:c013:1a4b:ecba::1/80"; }
      { addressConfig.Address = "2a01:4f8:c013:1a4b:ecba:1337::1/80"; }
    ];
    routes = [
      { routeConfig.Destination = "192.168.242.0/24"; }
      {
        routeConfig.Destination = "2a01:4f8:c013:1a4b:ecba::/80";
        routeConfig.PreferredSource = "2a01:4f8:c013:1a4b:ecba::1";
      }
    ];
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
  sops.secrets."buw/vpn/pass".owner = "root";
  sops.secrets."buw/vpn/config".owner = "root";
}
