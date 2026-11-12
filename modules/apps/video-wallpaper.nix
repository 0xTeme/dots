{
  # Video wallpaper for the Noctalia mpvpaper plugin. Installs mpvpaper, the player the plugin
  # runs, and libva-utils, which provides vainfo for checking hardware decoding. Decoding itself
  # comes from the global mpv setting in mpv.nix (hwdec = "auto-safe"), which uses VA-API on the
  # Intel GPU when it's available, so the video doesn't run on the CPU.
  flake.modules.nixos.video-wallpaper = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.mpvpaper
      pkgs.libva-utils
    ];
  };
}
