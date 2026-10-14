{
  # Smassh: Monkeytype-like TUI typing practice with in-app settings and time modes.
  flake.modules.homeManager.typing = { pkgs, ... }: {
    home.packages = [ pkgs.smassh ];
  };
}
