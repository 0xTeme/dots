{
  # Antigravity CLI. Closed-source, Google-controlled, installed via Google's own
  # script, not a Nix package. This file only owns what Nix actually can: making
  # it reachable, since the installer drops it in ~/.local/bin, not on PATH
  # by default.
  flake.modules.homeManager.agy = {
    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
