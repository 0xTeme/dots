{
  # Noctalia's Screen Recorder plugin is a thin wrapper; the actual recording
  # engine is this separate binary, which the plugin expects on PATH.
  flake.modules.nixos.screen-recorder = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.gpu-screen-recorder ];
  };
}
