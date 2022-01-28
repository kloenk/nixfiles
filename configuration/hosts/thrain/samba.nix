{ lib, config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      445
      137 138 139 # samba
    ];
    allowedUDPPorts = [
      445
      137 138 139 # netbios
    ];
  };

  fileSystems."/var/lib/samba" = {
    device = "/persist/data/samba-statedir";
    options = [ "bind" ];
  };
  fileSystems."/persist/Bag End" = {
    device = "smials/Bag End";
    fsType = "zfs";
  };

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = thrain
      netbios name = thrain
      security = user
      hosts allow = 192.168.178.0/24 192.168.242.0/24 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      kloenk = {
        path = "/persist/data/kloenk";
        "valid users" = "kloenk";
        public = "no";
        writable = "yes";
        "force user" = "kloenk";
        "fruit:aapl" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
      tm_share = {
        path = "/persist/data/timemachine";
        "valid users" = "kloenk";
        public = "no";
        writeable = "yes";
        "force user" = "kloenk";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
      "Bag End" = {
        path = "/persist/Bag End";
        "valid users" = "kloenk";
        public = "no";
        writeable = "yes";
        "force user" = "kloenk";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };

  systemd.targets.samba.unitConfig.RequiresMountsFor = [ "/var/lib/samba" "/persist/Bag End" ];
}
