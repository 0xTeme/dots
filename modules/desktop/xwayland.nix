{
  # niri has no built-in X11 support; since 25.08 it integrates with
  # xwayland-satellite automatically: the moment any X11 client tries to connect,
  # niri spawns it on demand and exports $DISPLAY. General compositor capability,
  # not tied to whatever specific app currently needs it.
  flake.modules.nixos.xwayland = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
