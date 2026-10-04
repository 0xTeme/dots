{
  flake.modules.nixos.foot = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.foot ];
  };

  # Nix owns foot.ini. Noctalia writes the palette to themes/noctalia, which is
  # included here, so the two never touch the same file.
  flake.modules.homeManager.foot = {
    xdg.configFile."foot/foot.ini".text = ''
      [main]
      include=~/.config/foot/themes/noctalia

      font=Iosevka Nerd Font Mono:size=13
      pad=14x10
    '';
  };
}
