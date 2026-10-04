{
  flake.modules.homeManager.fzf = {
    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
