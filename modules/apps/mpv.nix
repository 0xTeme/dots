{
  flake.modules.homeManager.mpv = {
    programs.mpv = {
      enable = true;

      # Whitelisted hardware decoders only; anything else falls back to software.
      config.hwdec = "auto-safe";
    };
  };
}
