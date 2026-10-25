{
  # Qt 6 apps (Telegram, for one) read their palette through qt6ct. NixOS's qt module
  # only accepts qt5ct as a platform theme, so this sets the Qt 6 variable directly.
  flake.modules.nixos.qt = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.qt6Packages.qt6ct ];
    environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";
  };
}
