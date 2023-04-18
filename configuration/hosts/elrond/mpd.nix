{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      6600 # MPD
      6601 # Audio stream
    ];
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/persist/Mac/Music";
    playlistDirectory = "/persist/Mac/Music/playlists";
    extraConfig = ''
      audio_output {
        type		"httpd"
        name		"MPD HTTP Stream"
        encoder		"vorbis"		# optional, vorbis oder lame
        port		"6601"
        always_on       "yes"
        quality		"5.0"			# entweder
        #	bitrate		"128"			# oder
        format		"44100:16:1"
      }
      audio_output {
        type "pipewire"
        name "Audio Stream"
      }
    '';

    # Optional:
    network.listenAddress =
      "any"; # if you want to allow non-localhost connections
    startWhenNeeded =
      true; # systemd feature: only start MPD service upon connection to its socket
  };

  services.mpd.user = "kloenk";
  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR =
      "/run/user/1000"; # User-id 1000 must match above user. MPD will look inside this directory for the PipeWire socket.
  };
}
