{ pkgs, lib, config, inputs, ... }:

{
  networking.firewall.allowedUDPPorts = [ 6002 ];
  environment.systemPackages = with pkgs;
    [
      # libjack2
      # jack2
      # qjackctl
      # jack2Full
      # jack_capture
      # carla
    ];
  services.upower.enable = true;

  services.pipewire.extraConfig.pipewire = {
    "30-rnnoise" = {
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
    "40-thrain-mpd" = {
      "context.modules" = [{
        name = "libpipewire-module-rtp-source";
        args = {
          "source.ip" = "192.168.178.248";
          "source.port" = "6002";
          "sess.ignore-ssrc" = true;
          "stream.props" = {
            "media.class" = "Audio/Source";
            "node.name" = "kloenk.recv.rtp.thrain";
          };
        };
      }];
    };
  };
}
