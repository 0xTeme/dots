{
  # Opening an image file renders it via Sixel instead of showing raw bytes.
  # Foot supports Sixel natively, so this needs no ueberzugpp bridge.
  flake.modules.homeManager.nixvim = { pkgs, ... }: {
    programs.nixvim.plugins.image = {
      enable = true;
      settings.backend = "sixel";
      settings.hijack_file_patterns = [ "*.png" "*.jpg" "*.jpeg" "*.gif" "*.webp" ];
    };

    # image.nvim shells out to ImageMagick to do the actual Sixel encoding.
    programs.nixvim.extraPackages = [ pkgs.imagemagick ];
  };
}
