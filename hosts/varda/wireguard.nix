{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedUDPPorts = [
    51820 # wg0
    51830 # wg-thrain
    51821 # wg-windows
  ];

  # NATING
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  networking.nftables.tables.nat = {
    family = "inet";
    content = ''
      chain postrouting {
        type nat hook postrouting priority srcnat;

        iifname "wg0" oifname { eth0, buw0 } masquerade;
        ip version 4 iifname "gre-*" oifname { "wg0", "buw0", "eth0" } masquerade;
        ip6 version 6 ip6 saddr != ${config.k.strongswan.babel.id.v6-tunnel-ip} iifname "gre-*" oifname "eth0" masquerade
      }
    '';
  };
  networking.firewall.extraForwardRules = ''
    iifname "wg0" accept;
    iifname "gre-*" oifname "wg0" accept;
    iifname "gre-*" oifname "eth0" accept;

    iifname "gre-*" oifname "wg-win" accept;
    iifname "wg-win" oifname "gre-*" accept;
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

      { # thrain
        AllowedIPs = [
          "192.168.242.101/32"
          "192.168.178.0/24"
          "2a01:4f8:c013:1a4b:ecba::101/128"
        ];
        PublicKey = "RiRB/fiZ/x88f78kRQasSwWYBuBjc5DxW2OFaa67zjg=";
        PersistentKeepalive = 21;
      }

      { # frodo
        AllowedIPs =
          [ "192.168.242.201/32" "2a01:4f8:c013:1a4b:ecba::201/128" ];
        PublicKey = "Onhxxt/h0JXB+6ES4y82AdtYKg/USbs7wn7iGlkgQCc=";
        PersistentKeepalive = 21;
      }
      { # windoof
        AllowedIPs =
          [ "192.168.242.202/32" "2a01:4f8:c013:1a4b:ecba::202/128" ];
        PublicKey = "aSkX5/y831rSZib/l0QhC1mmmaggNjdMNfQ0Qrz8rxA=";
        PersistentKeepalive = 21;
      }
      { # gloin
        AllowedIPs =
          [ "192.168.242.205/32" "2a01:4f8:c013:1a4b:ecba::205/128" ];
        PublicKey = "4Bwytj56G/CueL/P454SSE6Sq7wafGd/cJlFri5LxTw=";
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

  /* systemd.network.netdevs."30-wg-win" = {
       netdevConfig = {
         Kind = "wireguard";
         Name = "wg-win";
         Description = "Wireguard for windows domain controller traffic";
       };
       wireguardConfig = {
         ListenPort = 51821;
         PrivateKeyFile = config.sops.secrets."wireguard/wg-win".path;
       };
       wireguardPeers = [
         { # amdir
           AllowedIPs = [ "10.84.32.119/32" "fd4c:1796:6b06:bedd::1/128" ];
           PublicKey = "";
         }
         { # frodo-win11
           AllowedIPs = [ "10.84.32.120/32" "fd4c:1796:6b06:bedd::2/128" ];
           PublicKey = "";
         }
       ];
     };
  */

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
