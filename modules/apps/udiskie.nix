{
  # Mounts USB drives. The Noctalia Udiskie Manager plugin calls this tool.
  flake.modules.homeManager.udiskie = { pkgs, ... }: {
    home.packages = [ pkgs.udiskie ];
  };
}
