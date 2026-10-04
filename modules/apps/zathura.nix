{
  flake.modules.homeManager.zathura = {
    programs.zathura = {
      enable = true;

      # Noctalia writes noctaliarc next to zathurarc. Its template only renders
      # when ~/.config/zathura exists, which this file guarantees.
      extraConfig = ''
        include noctaliarc
      '';
    };
  };
}
