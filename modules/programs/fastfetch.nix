{
  flake.modules.homeManager.fastfetch = {
    programs.fastfetch = {
      enable = true;

      # Colors come from the terminal palette, which Noctalia already pushes live
      # into Foot, so no separate theming is needed here.
      settings = {
        logo.type = "small";

        modules = [
          "title"
          "separator"
          "os"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "wm"
          "terminal"
          "cpu"
          "gpu"
          "memory"
          "disk"
          "battery"
          "break"
          "colors"
        ];
      };
    };
  };
}
