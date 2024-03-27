{ pkgs, ... }:

{
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
              "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_6__source";
          };
          "playback.props" = {
            "node.name" = "effect.kloenk.rnnoise.playback";
            "node.nick" = "RNNoise playback";
            "media.class" = "Audio/Source";
          };
        };
      }];
    };
  };
}
