{
  # Fastfetch with the NixOS logo on the left and a short text block on the right. The module
  # list is kept to the lines that matter on this laptop, including battery, since fastfetch runs
  # each query once at startup and a shorter list starts faster.
  flake.modules.homeManager.fastfetch = {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          type = "auto";
          source = "nixos";
          position = "left";
          padding = {
            top = 1;
            right = 3;
          };
        };
        display = {
          separator = "  ";
        };
        modules = [
          "title"
          "separator"
          "os"
          "kernel"
          "uptime"
          "shell"
          "wm"
          "terminal"
          "cpu"
          "memory"
          "battery"
        ];
      };
    };
  };
}
