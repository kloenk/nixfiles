{ lib, pkgs, config, ... }:

let
  ports = {
    ssh = 62957;
  };
in {
  fileSystems."/var/lib/machines/rbuild" = {
    device = "/persist/data/fedora-32";
    fsType = "none";
    options = [ "bind" ];
  };
  fileSystems."/persist/data/rbuild/cache" = {
    device = "/dev/disk/by-uuid/4a78ab01-9338-4062-9f9b-c56db755efb3";
    fsType = "xfs";
  };

  networking.firewall.allowedTCPPorts = [
    ports.ssh # ssh
  ];

  systemd.sockets.rbuild = {
    description = "SSH socket for durin-rbuild systemd container";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ (toString ports.ssh) ];
    socketConfig = {
      BindIPv6Only = "both";
    };
  };

  systemd.services.rbuild = {
    description = "Airlink build systemd container";
    wantedBy = [ "machines.target" ];
    wants = [ "modprobe@tun.service" "modprobe@loop.service" "modprobe@dm-mod.service" ];
    partOf = [ "machines.target" ];
    before = [ "machines.target" ];
    after = [
      "network.target"
      "systemd-resolved.service"
      "modprobe@tun.service"
      "modprobe@loop.service"
      "modprobe@dm-mod.service"
      "modprobe@kvm.service"
    ];
    restartIfChanged = false;

    unitConfig.RequiresMountsFor = [
      "/var/lib/machines/rbuild"
      "/persist/data/rbuild/cache"
      "/persist/data/rbuild/out"
      "/persist/data/airlink"
    ];

    serviceConfig = {
      ExecStart = "${pkgs.systemd}/bin/systemd-nspawn --quiet --keep-unit --boot --network-veth -U --settings=override --machine=rbuild";
      KillMode = "mixed";
      Type = "notify";
      RestartForceExitStatus = "133";
      SuccessExitStatus = "133";
      Slice = "machine.slice";
      Delegate = "yes";
      TasksMax = "16384";
      WatchdogSec = "3min";

      # Enforce a strict device policy, similar to the one nspawn configures when it
      # allocates its own scope unit. Make sure to keep these policies in sync if you
      # change them!
      DevicePolicy = "closed";
      DeviceAllow = [
        "/dev/net/tun rwm"
        "char-pts rw"
        "/dev/loop-control rw"
        "block-loop rw"
        "block-blkext rw"
        "/dev/kvm rwm"
        "/dev/mapper/control rw"
        "block-device-mapper rw"
      ];
    };
  };

  systemd.nspawn.rbuild = {
    networkConfig = {
      VirtualEthernet = "yes";
      Bridge = [ "br0" ];
      Port = [ "62957" ];
    };
    filesConfig = {
      Bind = [
        "/persist/data/rbuild/cache:/home/fin/cache"
        "/persist/data/rbuild/out:/home/fin/packages"
        "/persist/data/airlink/proj:/home/fin/airlink"
        "/persist/data/airlink/:/home/fin/proj"
        "/dev/kvm"
      ];
    };
    execConfig = {
      LinkJournal = "try-guest";
      NotifyReady = "yes";
      PrivateUsers = "yes";
      Boot = "yes";
    };
  };
}