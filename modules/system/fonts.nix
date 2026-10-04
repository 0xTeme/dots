{
  flake.modules.nixos.fonts = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      iosevka
      (pkgs.iosevka-bin.override { variant = "Aile"; })
      (pkgs.iosevka-bin.override { variant = "Etoile"; })
      noto-fonts
      noto-fonts-color-emoji
    ];

    fonts.fontconfig.defaultFonts = {
      sansSerif = [ "Iosevka Aile" ];
      serif = [ "Iosevka Etoile" ];
      monospace = [ "Iosevka Nerd Font Mono" ];
    };
  };
}
