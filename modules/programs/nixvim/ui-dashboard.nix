{
  # Opening nvim with no file now shows a real dashboard instead of a blank buffer.
  flake.modules.homeManager.nixvim.programs.nixvim.plugins.alpha = {
    enable = true;
    theme = "dashboard";
  };
}
