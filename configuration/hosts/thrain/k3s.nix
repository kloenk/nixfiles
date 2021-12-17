{ config, lib, pkgs, ... }:

let
  flannel = builtins.toJSON {
    name = "cbr0";
    cniVersion = "0.3.1";
    plugins = [
      {
        type = "flannel";
        delegate = {
          hairpinMode = true;
          forceAddress = true;
          isDefaultGateway = true;
        };
      }
      {
        type = "portmap";
        capabilities = {
          portMappings = true;
        };
      }
    ];
  };
in {

  fileSystems."/var/lib/kubelet" = {
    device = "/persist/data/kubelet";
    options = [ "bind" ];
  };
  fileSystems."/var/lib/rancher" = {
    device = "/persist/data/rancher";
    options = [ "bind" ];
  };

  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.k3s = {
    enable = true;
    role = "server";
    docker = lib.mkForce false;
    extraFlags = "--flannel-backend=host-gw --container-runtime-endpoint unix:///run/containerd/containerd.sock";
  };
  virtualisation.containerd = {
    enable = true;
    settings = {
      version = 2;
      plugins."io.containerd.grpc.v1.cri" = {
        cni.conf_dir = "${pkgs.writeTextDir "net.d/10-flannel.conflist" flannel}/net.d";
        # FIXME: upstream
        cni.bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
          mkdir -p $out
          ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
        ''}";
        systemd_cgroup = true;
      };
    };
  };

  environment.systemPackages = [ config.services.k3s.package ];
}
