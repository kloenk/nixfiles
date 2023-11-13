{ pkgs, lib, config, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    helvum
    mpc-cli

    pavucontrol
    # libjack2
    # jack2
    # qjackctl
    # jack2Full
    # jack_capture
    # carla
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
    wireplumber.enable = true;
    systemWide = false;
  };

  environment.etc."pipewire/pipewire.conf.d/30-rnnoise.conf".text =
    builtins.toJSON {
      "context.properties"."default.clock.rate" = 48000;
      "context.modules" = [{
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Noise Cancelling";
          "media.name" = "Noise Cancelling";
          "filter.graph" = {
            nodes = [{
              type = "ladspa";
              name = "rnnoise";
              plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
              label = "noise_suppressor_mono";
              control = { "VAD Threshold (%)" = 50.0; };
            }];
          };
          "audio.position" = [ "FL" "FR" ];
          "capture.props" = {
            "node.name" = "effect.kloenk.rnnoise.capture";
            "node.passive" = true;
            "node.nick" = "RNNoise capture";
            "node.target" =
              "alsa_input.usb-Yamaha_Corporation_AG06_AG03-00.analog-stereo";
          };
          "playback.props" = {
            "node.name" = "effect.kloenk.rnnoise.playback";
            "node.nick" = "RNNoise playback";
            "media.class" = "Audio/Source";
          };
        };
      }];
    };
}
