{
  # Qt 6 apps (Telegram, for one) read their palette through qt6ct. NixOS's qt module
  # only accepts qt5ct, so the Qt 6 variable is set directly.
  flake.modules.nixos.qt = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.qt6Packages.qt6ct ];
    environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";
  };

  # qt6ct only points at the palette. Noctalia's Qt template writes the colors to
  # colors/noctalia.conf, so Nix owns this pointer and Noctalia owns the colors.
  flake.modules.homeManager.qt = { config, ... }: {
    xdg.configFile."qt6ct/qt6ct.conf".text = ''
      [Appearance]
      color_scheme_path=${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf
      custom_palette=true
      style=Fusion
    '';
  };
}
