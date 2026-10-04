{
  flake.modules.nixos.cursor = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.bibata-cursors ];
  };
}
