{ pkgs, ... }:

{
  services.usbmuxd = {
    enable = true;
    #package = pkgs.usbmuxd2;
  };

  environment.systemPackages = with pkgs; [
    libimobiledevice
    idevicerestore
    ifuse
  ];

  systemd.network = {
    links."10-iph0" = {
      matchConfig = { Driver = "ipheth"; };
      linkConfig.Name = "iph0";
    };
    networks."10-iph0" = {
      name = "iph0";
      DHCP = "yes";
    };
  };
}
