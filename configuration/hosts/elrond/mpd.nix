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
        name "MDP output"
      }
    '';

    # Optional:
    network.listenAddress = "any"; # if you want to allow non-localhost connections
    startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
  };
}
