{
  # Themes and icons. Nix installs them and Noctalia picks them. The Papirus template
  # sets the icon theme with gsettings, so glib (which provides gsettings) and the
  # desktop schemas it reads must be on the system path.
  flake.modules.nixos.gtk-dark = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.adw-gtk3
      pkgs.papirus-icon-theme
      pkgs.glib
      pkgs.gsettings-desktop-schemas
    ];
  };
}
