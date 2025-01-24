{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [ helvum mpc-cli pavucontrol ];

  services.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    pulse.enable = true;
  };
}
