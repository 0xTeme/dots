{
  flake.modules.homeManager.mpd = { config, ... }: {
    services.mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Music";

      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire"
        }

        # Cava reads visualizer data from this, separate from actual playback.
        audio_output {
          type "fifo"
          name "cava fifo"
          path "/tmp/mpd.fifo"
          format "44100:16:2"
        }

        auto_update "yes"
      '';
    };
  };
}
