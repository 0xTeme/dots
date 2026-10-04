{
  flake.modules.nixos.cursor = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.bibata-cursors ];
  };

  flake.modules.homeManager.cursor = { pkgs, lib, ... }: {
    # Map each theme individually so Noctalia can still write to ~/.icons/default/index.theme
    xdg.dataFile = lib.genAttrs [
      "icons/Bibata-Modern-Amber"
      "icons/Bibata-Modern-Amber-Right"
      "icons/Bibata-Modern-Classic"
      "icons/Bibata-Modern-Classic-Right"
      "icons/Bibata-Modern-Ice"
      "icons/Bibata-Modern-Ice-Right"
      "icons/Bibata-Original-Amber"
      "icons/Bibata-Original-Amber-Right"
      "icons/Bibata-Original-Classic"
      "icons/Bibata-Original-Classic-Right"
      "icons/Bibata-Original-Ice"
      "icons/Bibata-Original-Ice-Right"
    ] (name: {
      source = "${pkgs.bibata-cursors}/share/${name}";
    });
  };
}
