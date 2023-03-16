{ pkgs, lib, config, ... }:

{
    environment.systemPackages = with pkgs; [
        helvum
        mpc-cli

        pavucontrol libjack2 jack2 qjackctl jack2Full jack_capture
        carla cadence
    ];
    services.upower.enable = true;
    hardware.pulseaudio.enable = lib.mkForce false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa = {
            enable = true;
            support32Bit = true;
        };
        jack = {
            enable = true;
            #support32Bit = true;
        };
        pulse = {
            enable = true;
            #support32Bit = true;
        };
        media-session.enable = false;
        wireplumber.enable = true;
        config = {
            pipewire = {
                "context.properties"."default.clock.rate" = 48000;
            };
        };
    };

}