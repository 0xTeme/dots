{
  # Image rendering for the dashboard and for opening image files. window_overlap_clear_enabled
  # lets the plugin hide an image while another window covers it, and show it again once that
  # window closes. That's what keeps the splash from flashing over the picker and staying gone.
  flake.modules.homeManager.nixvim.programs.nixvim.plugins.image = {
    enable = true;
    settings = {
      backend = "sixel";
      hijack_file_patterns = [ "*.png" "*.jpg" "*.jpeg" "*.gif" "*.webp" ];
      window_overlap_clear_enabled = true;
    };
  };
}
