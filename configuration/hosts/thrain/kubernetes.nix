{ config, lib, pkgs, ... }:

let
  kubeMasterIP = "192.168.178.248";
  kubeMasterHostname = "thrain.fritz.box";
  kubeMasterAPIServerPort = 6443;
in {
  fileSystems."/var/lib/kubernetes" = {
    device = "/persist/data/kubernetes";
    options = [ "bind" ];
  };
  fileSystems."/var/lib/etcd" = {
    device = "/persist/data/etcd";
    options = [ "bind" ];
  };
  fileSystems."/var/lib/cfssl" = {
    device = "/persist/data/cfssl";
    options = [ "bind" ];
  };
  fileSystems."/var/lib/kubelet" = {
    device = "/persist/data/kubelet";
    options = [ "bind" ];
  };

  fileSystems."/etc/kube-flannel" = {
    device = "/persist/data/kube-flannel-etc";
    options = [ "bind" ];
  };
  fileSystems."/etc/kubernetes" = {
    device = "/persist/data/kubernetes-etc";
    options = [ "bind" ];
  };

  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # packages for administration tasks
  environment.systemPackages = with pkgs; [ kompose kubectl kubernetes ];

  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = kubeMasterHostname;
    apiserverAddress =
      "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };

  virtualisation.containerd.settings.plugins."io.containerd.grpc.v1.cri".containerd.snapshotter =
    "overlayfs";
}
