# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./moodle.nix
    ./restic.nix

    ../../default.nix
    ../../common
  ];

  services.qemuGuest.enable = true;

  users.users.kloenk = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000611120054"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEDZjcKdYViw9cPrLNkO37+1NgUj8Ul1PTlbXMMwlMR kloenk@kloenkX"
    ];
  };

  security.acme.email = lib.mkForce "segelschule@unterbachersee.de";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "moodle-usee"; # Define your hostname.
  networking.useDHCP = false;
  #networking.firewall.logRefusedConnections = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  /*networking.interfaces.ens18 = {
    ipv4.addresses = [{
      address = "5.9.118.94";
      prefixLength = 32;
    }];
    ipv6.addresses = [{
      address = "2a01:4f8:162:6343::4";
      prefixLength = 128;
    }];
    #  ipv4.routes [{}];
    ipv4.routes = [
      { address = "5.9.118.93"; prefixLength = 32; }
    ];
    ipv6.routes = [
      { address = "2a01:4f8:162:6343::3"; prefixLength = 128; }
    ];
  };
  networking.defaultGateway = {
    address = "5.9.118.73";
    interface = "ens18";
  };

  networking.defaultGateway6 = {
    address = "2a01:4f8:162:6343::2";
    interface = "ens18";
  };

  networking.nameservers = [ "1.1.1.1" "192.168.178.1" "2001:4860:4860::8888" ];*/
  systemd.network.networks."20-ens18" = {
    name = "ens18";
    DHCP = "no";
    dns = [ "1.1.1.1" "2001:4860:4860::8888" ];
    addresses = [
      {
        addressConfig.Address = "5.9.118.94/32";
      }
      {
        addressConfig.Address = "2a01:4f8:162:6343::4/128";
      }
    ];
    routes = [
      {
        routeConfig.Gateway = "5.9.118.73";
        routeConfig.GatewayOnLink = true;
      }
      {
        routeConfig.Gateway = "2a01:4f8:162:6343::2";
        routeConfig.GatewayOnLink = true;
      }
      { 
        routeConfig.Destination = "5.9.118.93";
      }
      {
        routeConfig.Destination = "2a01:4f8:162:6343::3";
      }
    ];
  };

  # Select internationalisation properties.
  console.keyMap = lib.mkForce "de";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ wget vim nano tmux htop nload ];


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 62954 80 443 ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.holger = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAEXSO6mRngKzCQgAGDlGwr9EOUAwySgIK/U8+ilsywV8XKmBp5i2Vo8JvrRnbpBomKvCZSrZVNP9OVnHHWlYcjevwFDvxkv+Kwpn3O+m70ijFeYgwSNy4tmFfDKDHgnRyto220t7QqDciNjvFoQc9FT78tAWxzM1WkdBwFJYPU/7ZZfwQ== Schluempfli@trudeltiere.de"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  # autoUpgrade  
  /*system.autoUpgrade = {
    allowReboot = true;
    enable = true;
  };*/
  system.autoUpgrade.enable = true;
  nix.gc.automatic = true;

  # node-exporter foo
  /*services.prometheus.exporters.node.enable = true;
  services.prometheus.exporters.node.enabledCollectors = [ "logind" "systemd" ];
  services.httpd.virtualHosts."moodle-usee.kloenk.de" = {
    enableACME = true;
    #forceSSL = true;
    addSSL = true;
    locations."/node-exporter/".proxyPass = "http://127.0.0.1:9100/";
  };*/

  # wireguard
  networking.wireguard.enable = true;
  networking.wireguard.interfaces.usee0 = {
    ips = [ "192.168.56.2/24" ];
    peers = [
      {
        allowedIPs = [ "192.168.56.0/24" ];
        endpoint = "manwe.kloenk.dev:51822";
        publicKey = "CIzg7RjyEO9Df2muABFyGKDfuWBBxvy1MA2ONOhw+lo=";
      }
    ];
    privateKeyFile = "/var/src/secrets/usee0.key";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

