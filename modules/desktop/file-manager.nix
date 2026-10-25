{
  # Nautilus (GNOME Files): GTK 4 on libadwaita, the toolkit Noctalia's GTK 4 template
  # targets, so the palette applies directly. gvfs provides MTP, which is how phones
  # show up, and dconf is what GNOME apps read their settings from.
  flake.modules.nixos.file-manager = { pkgs, ... }: {
    programs.dconf.enable = true;
    services.gvfs.enable = true;
    environment.systemPackages = [ pkgs.nautilus ];
  };
}
