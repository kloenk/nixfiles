{ config, lib, pkgs, ... }:

{

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
  };

  environment.systemPackages = [ config.services.k3s.package ];
}
