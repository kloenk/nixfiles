{ config, pkgs, ... }:

let musicPath = "/persist/public/Music";
in {
  imports = [ ../../../profiles/desktop/sound.nix ];

  networking.firewall.allowedTCPPorts = [
    6600 # MPD
    6601 # HTTP audio stream
  ];
  networking.firewall.allowedUDPPorts = [ 6002 ];

  services.mpd = {
    enable = true;
    musicDirectory = musicPath;
    playlistDirectory = musicPath + "/playlists";
    extraConfig = ''
      audio_output {
        type       "httpd"
        name       "MPD HTTP Audio Stream"
        encoder    "vorbis"
        port       "6001"
        quality    "5.0"
        format     "44100:16:1"
      }
      audio_output {
        type "pipewire"
        name "kloenk.pipewire"
      }
    '';

    network.listenAddress = "any";
    startWhenNeeded = true;
  };

  services.mpd.user = "kloenk";

  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR =
      "/run/user/1000"; # User-id 1000 must match above user. MPD will look inside this directory for the PipeWire socket.
  };

  environment.etc."pipewire/pipewire.conf.d/40-elrond.conf".text =
    builtins.toJSON {
      "context.modules" = [
        {
          name = "libpipewire-module-rtp-sink";
          args = {
            "destination.ip" = "192.168.178.247";
            "destination.port" = "6002";
            "stream.props" = {
              "media.class" = "Audio/Sink";
              "node.name" = "kloenk.send.rtp.elrond";
              "node.target" = "kloenk.mpd.pipewire";
            };
          };
        }
        {
          name = "libpipewire-module-vban-send";
          args = {
            "local.ifname" = "eth0";
            "stream.props" = {
              "node.name" = "kloenk.send.vban";
              "media.class" = "Audio/Sink";
              "node.target" = "mpd.kloenk.pipewire";
            };
          };
        }
      ];
    };
}
