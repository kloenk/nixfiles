{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.k3s = {
    enable = true;
    role = "server";
  };

  environment.systemPackages = [ config.services.k3s.package ];
}
