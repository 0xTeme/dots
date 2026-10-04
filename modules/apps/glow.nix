{
  flake.modules.homeManager.glow = { config, pkgs, ... }: {
    home.packages = [ pkgs.glow ];

    # Noctalia writes noctalia.json; glow only points at it.
    xdg.configFile."glow/glow.yml".text = ''
      style: "${config.xdg.configHome}/glow/noctalia.json"
    '';
  };
}
