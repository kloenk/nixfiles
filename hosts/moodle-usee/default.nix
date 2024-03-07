# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./backup-module.nix

    ./hardware-configuration.nix
    ./links.nix

    ./moodle.nix

    ../../profiles/telegraf.nix
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

  security.acme.defaults.email = lib.mkForce "segelschule@unterbachersee.de";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
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
  /* networking.interfaces.ens18 = {
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

     networking.nameservers = [ "1.1.1.1" "192.168.178.1" "2001:4860:4860::8888" ];
  */

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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD1U2lbVQZLxjKrbXfwcPdFDlnqkxm2A+Q/yXv5J/HwzmQfrted75T/iRTfRU84clLdRwEp2PB2Ro+ElZFpMKTT+hP8L/CTpOodeEWS8FOqfz9w7qHDKTV3IpVDkDlBc5JAdD59OWj+zyYYYM/YRvm0OUPn/JdKe0uwdHrVPFOxGWxrdz78zK39MOeDZnBwU94g9dp0aX6tTWTcqXkuLul/1n1booSBvKfLCakwCfTM3iqTD8JBkYjQW23niy0EyJK7QqtEIkuvlkFF6yY+G44NBQQB3w3Z2Y5tiwz3/LLZG9AGlWVAWA2irucNzm6+DysPBuAc66VEzeBmp3RCWtzqSCBlcUxjL3CnX0KiHZxegCCOxjcifG7OxyH9QyNSdAjUQJUUcZsl7rf9JViDgqT6N95vzRAHPVZhVju0yry+k5WwMUVfSg77qH/xLNKIBp870w2UCOR7QxvIsj1+uX4+mQOOMDk5sTauJo9333MfwNK3MF/p09p0hVfMR2bFdxje+KDzVANQgjA27GjIUfdSyxFU2jDYvWhP4s2eKvd4Dyu2/NGnJS4KdU6vo7rf/K80AtH8Jp0tpNeR3bvblYJYcoLLd9qFEJ2eGiLFuTBNb64SqdOoBd8P4gBQ8uS751UNZ8YNkJTA/0LmXVLcirg0tishnlac5mpEP8/utJkcvw== cardno:000606914775"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  # autoUpgrade  
  /* system.autoUpgrade = {
       allowReboot = true;
       enable = true;
     };
  */
  system.autoUpgrade.enable = true;
  nix.gc.automatic = true;

  # node-exporter foo
  /* services.prometheus.exporters.node.enable = true;
     services.prometheus.exporters.node.enabledCollectors = [ "logind" "systemd" ];
     services.httpd.virtualHosts."moodle-usee.kloenk.de" = {
       enableACME = true;
       #forceSSL = true;
       addSSL = true;
       locations."/node-exporter/".proxyPass = "http://127.0.0.1:9100/";
     };
  */

  services.telegraf.extraConfig = { global_tags.tenant = "usee"; };
  services.nginx.virtualHosts."telegraf.moodle-usee.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/metrics" = {
      proxyPass = "http://[::1]:9273/metrics";
      extraConfig = ''
        allow 127.0.0.1/8;
        allow ::/8;
        allow 168.119.57.172;
        allow 2a01:4f8:c013:1a4b::/112;
        deny all;
      '';
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

