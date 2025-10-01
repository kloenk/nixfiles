{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ sddm-astronaut sddm-celeste ];
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "celeste-sddm";
      #theme = "sddm-astronaut-theme";
      #extraPackages = with pkgs; [ sddm-celeste ];
      extraPackages = with pkgs; [ sddm-astronaut ];
    };
  };
}
