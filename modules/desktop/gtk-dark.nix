{
  # Installs the GTK themes and icons. Nix does not select them. Noctalia's GTK script
  # picks adw-gtk3 or adw-gtk3-dark and sets the color scheme on every light or dark
  # change, and the Papirus template recolors folder icons to match the palette. If Nix
  # also pinned a theme, the two would overwrite each other.
  flake.modules.nixos.gtk-dark = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.adw-gtk3
      pkgs.papirus-icon-theme
    ];
  };
}
