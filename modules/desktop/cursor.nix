{
  flake.modules.nixos.cursor = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.bibata-cursors ];
  };

  flake.modules.homeManager.cursor = { pkgs, ... }: {
    home.file.".icons".source = "${pkgs.bibata-cursors}/share/icons";
  };
}
