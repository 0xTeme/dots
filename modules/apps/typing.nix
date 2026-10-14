{
  # Terminal typing practice. ttyper is packaged in nixpkgs and launched through
  # the Mod+Ctrl+Shift+T bind. The tool I originally wanted, typa, isn't in nixpkgs,
  # so it isn't installed here.
  flake.modules.homeManager.typing = { pkgs, ... }: {
    home.packages = [ pkgs.ttyper ];
  };
}
